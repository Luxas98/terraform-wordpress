import time
from api.extensions.api import api
from .blueprint import test


@api.route(test, '/current', methods=['GET'])
def get_current_time(_version):
    return {'time': time.time()}
