#Base Image using pythonslim
FROM python:3.8-slim

#create working directory.
WORKDIR /app

#Copy dependencies
COPY requirements.txt .

#Installing dependemcy
RUN pip install --no-cache-dir -r requirements.txt

#cCopy source code into work directory
COPY . .

#make migration to database

RUN python manage.py makemigrations

RUN python manage.py migrate

RUN python manage.py createsuperuser

EXPOSE 3000

CMD ["python3", "manage.py", "runserver", "0.0.0.0:3000"]