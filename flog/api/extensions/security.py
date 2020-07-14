from api.extensions import db
from api.security import SQLAlchemyUserDatastore, Security
from api.security.models import User, Role

user_datastore = SQLAlchemyUserDatastore(db, User, Role)
security = Security(datastore=user_datastore)
