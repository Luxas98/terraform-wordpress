"""
Flask Application Factory Pattern
http://flask.pocoo.org/docs/0.12/patterns/appfactories/
"""
import sys
from flask import Flask as BaseFlask
from flask.helpers import get_debug_flag
from flask_sqlalchemy import SQLAlchemy

import logging

from api.config import (
    BaseConfig,
    DevConfig,
    ProdConfig,
    EXTENSIONS,
    DEFERRED_EXTENSIONS
)

from api.logger import logger
from api.magic import (
    get_bundles,
    get_commands,
    get_extensions,
)


class Flask(BaseFlask):
    bundles = []
    models = {}
    serializers = {}


def create_app():
    """Creates a pre-configured Flask application.

    Defaults to using :class:`backend.config.ProdConfig`, unless the
    :envvar:`FLASK_DEBUG` environment variable is explicitly set to "true",
    in which case it uses :class:`backend.config.DevConfig`. Also configures
    paths for the templates folder and static files.
    """
    return _create_app(DevConfig if get_debug_flag() else ProdConfig)


def _create_app(config_object: BaseConfig, **kwargs):
    """Creates a Flask application.

    :param object config_object: The config class to use.
    :param dict kwargs: Extra kwargs to pass to the Flask constructor.
    """
    app = Flask(__name__, **kwargs)
    app = register_app(app, config_object)
    app = register_logger(app)
    return app


def register_logger(app):
    gunicorn_error_logger = logging.getLogger('gunicorn.error')
    app.logger.handlers.extend(gunicorn_error_logger.handlers)
    return app

def register_models(app):
    """Register bundle models."""
    models = {}
    for bundle in app.bundles:
        # try:
        for model_name, model_class in bundle.models:
            models[model_name] = model_class
        # except AttributeError as e:
        #     print(f'No models for bundle {bundle.module_name}')

    app.models = models

def register_admins(app):
    """Register bundle admins."""
    from api.extensions import db
    from api.extensions.admin import admin

    for bundle in app.bundles:
        if bundle.admin_icon_class:
            admin.category_icon_classes[bundle.admin_category_name] = bundle.admin_icon_class

        for ModelAdmin in bundle.model_admins:
            model_admin = ModelAdmin(ModelAdmin.model,
                                     db.session,
                                     category=bundle.admin_category_name,
                                     name=ModelAdmin.model.__plural_label__)

            # workaround upstream bug where certain values set as
            # class attributes get overridden by the constructor
            model_admin.menu_icon_value = getattr(ModelAdmin, 'menu_icon_value', None)
            if model_admin.menu_icon_value:
                model_admin.menu_icon_type = getattr(ModelAdmin, 'menu_icon_type', None)

            admin.add_view(model_admin)



def register_app(app, config_object):
    app.bundles = list(get_bundles())

    configure_app(app, config_object)

    extensions = dict(get_extensions(EXTENSIONS))
    register_extensions(app, extensions)

    register_blueprints(app)
    register_models(app)
    register_serializers(app)
    register_admins(app)

    deferred_extensions = dict(get_extensions(DEFERRED_EXTENSIONS))
    extensions.update(deferred_extensions)
    register_extensions(app, deferred_extensions)

    register_cli_commands(app)
    register_shell_context(app, extensions)

    return app


def configure_app(app, config_object):
    """General application configuration:

    - register the app's config
    """
    app.config.from_object(config_object)


def register_extensions(app, extensions):
    """Register and initialize extensions."""
    for extension in extensions.values():
        extension.init_app(app)


def register_blueprints(app):
    """Register bundle views."""
    # disable strict_slashes on all routes by default
    if not app.config.get('STRICT_SLASHES', False):
        app.url_map.strict_slashes = False

    # register blueprints
    for bundle in app.bundles:
        print(f'Processing bundle {bundle.module_name}')
        for blueprint in bundle.blueprints:
            # rstrip '/' off url_prefix because views should be declaring their
            # routes beginning with '/', and if url_prefix ends with '/', routes
            # will end up looking like '/prefix//endpoint', which is no good
            print(f'Registering blueprint for {blueprint.url_prefix}')
            url_prefix = (blueprint.url_prefix or '').rstrip('/')
            app.register_blueprint(blueprint, url_prefix=url_prefix)


def register_serializers(app):
    """Register bundle serializers."""
    serializers = {}
    for bundle in app.bundles:
        print(f'Processing bundle {bundle.module_name}')
        for name, serializer_class in bundle.serializers:
            print(f'Registering serializers for {serializer_class}')
            serializers[name] = serializer_class
    app.serializers = serializers


def register_cli_commands(app):
    """Register all the Click commands declared in :file:`backend/commands` and
    each bundle's commands"""
    commands = list(get_commands())
    for bundle in app.bundles:
        commands += list(bundle.command_groups)
    for name, command in commands:
        if name in app.cli.commands:
            logger.error(f'Command name conflict: "{name}" is taken.')
            sys.exit(1)
        app.cli.add_command(command)


def register_shell_context(app, extensions):
    """Register variables to automatically import when running `python manage.py shell`."""

    def shell_context():
        ctx = {}
        ctx.update(extensions)
        ctx.update(app.models)
        ctx.update(app.serializers)
        return ctx

    app.shell_context_processor(shell_context)
