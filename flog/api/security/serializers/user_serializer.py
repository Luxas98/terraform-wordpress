import re

from api.apibase import ModelSerializer, fields, validates, ValidationError

from ..models import User

NON_ALPHANUMERIC_RE = re.compile(r'[^\w]')


class UserSerializer(ModelSerializer):
    email = fields.Email(required=True)
    roles = fields.Nested('RoleSerializer', many=True)

    class Meta:
        model = User
        # exclude = ('confirmed_at', 'updated_at', 'user_roles')
        exclude = ()
        dump_only = ('active', 'roles')
        load_only = ('password',)

    @validates('email')
    def validate_email(self, email):
        existing = User.get_by(email=email)
        if existing and (self.is_create() or existing != self.instance):
            raise ValidationError('Sorry, that email is already taken.')

    @validates('username')
    def validate_username(self, username):
        if re.search(NON_ALPHANUMERIC_RE, username):
            raise ValidationError('Username should only contain letters, numbers and/or the underscore character.')

        existing = User.get_by(username=username)
        if existing and (self.is_create() or existing != self.instance):
            raise ValidationError('Sorry, that username is already taken.')

    @validates('password')
    def validate_password(self, value):
        if not value or len(value) < 8:
            raise ValidationError('Password must be at least 8 characters long.')
