import os

CELERY_BROKER_URL = os.gentenv('CELERY_BROKER_URL') or 'amqp://guest:guest@rabbitmq:5672//'
KRAKEN_BROKER_URL = os.gentenv('KRAKEN_BROKER_URL') or 'amqp://guest:guest@rabbitmq:5672//'

SQLALCHEMY_DATABASE_URI = os.gentenv('SQLALCHEMY_DATABASE_URI') or 'postgresql://navitia:navitia@database/jormungandr'

# If the presence of the cities db is not needed, un-comment the following line
# CITIES_DATABASE_URI = None

REDIS_HOST = os.gentenv('CELERY_BROKER_HOST') or 'redis'

INSTANCES_DIR = '/etc/tyr.d'
