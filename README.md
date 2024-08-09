# SE-LAB-AZ5

# استقرار پروژه

## فایل `docker-compose.yml`

فایل `docker-compose.yml` شامل تنظیمات لازم برای ایجاد و اجرای کانتینرهای `web` و `db` می‌باشد:

### سرویس `web`:
مسئول اجرای وب‌سرور Django است. در این سرویس، از دایرکتوری فعلی پروژه به عنوان مسیر ساخت ایمیج Docker استفاده می‌شود و این ایمیج بر اساس فایل Dockerfile موجود در همین مسیر ساخته می‌شود. برای راه‌اندازی وب‌سرور، ابتدا اسکریپتی به نام wait_for_postgres.sh اجرا می‌شود که هدف آن اطمینان از برقراری ارتباط با پایگاه داده PostgreSQL است. پس از برقراری این ارتباط، سرور Django راه‌اندازی می‌شود. این سرویس پورت 8000 را از درون کانتینر به همان پورت بر روی ماشین میزبان متصل می‌کند، به این ترتیب می‌توانید از طریق مرورگر به وب‌سرور دسترسی پیدا کنید. همچنین، دایرکتوری فعلی پروژه به مسیر /app درون کانتینر متصل شده است تا تغییرات فایل‌ها به‌صورت هم‌زمان در محیط توسعه اعمال شوند. این سرویس همچنین به گونه‌ای پیکربندی شده است که تا زمانی که سرویس پایگاه داده به‌طور کامل بارگذاری نشده، شروع به کار نمی‌کند. در نهایت، متغیرهای محیطی لازم برای پیکربندی Django و ارتباط با پایگاه داده در این سرویس تنظیم شده‌اند؛ متغیرهایی مانند حالت دیباگ، میزبان‌های مجاز، موتور پایگاه داده، نام پایگاه داده، نام کاربری، رمز عبور، میزبان و پورت پایگاه داده.

### سرویس `db`:
سرویس db مربوط به پایگاه داده PostgreSQL است که از تصویر Docker نسخه 16.3 برای راه‌اندازی استفاده می‌کند. این سرویس از یک volume نام‌دار برای ذخیره‌سازی داده‌های پایگاه داده به‌صورت دائمی بهره می‌برد، که این حجم تضمین می‌کند که داده‌ها حتی پس از خاموش یا حذف شدن کانتینرها باقی بمانند. پورت 5432 درون کانتینر نیز به همان پورت بر روی ماشین میزبان متصل شده است تا امکان دسترسی به پایگاه داده از خارج از کانتینر فراهم شود. علاوه بر این، متغیرهای محیطی مورد نیاز برای تنظیم نام پایگاه داده، نام کاربری و رمز عبور در این سرویس تعیین شده‌اند. <br> <br>

در زیر کد این فایل را مشاهده می‌کنید: <br> <Br>
```yml
version: '3.9'

services:
  web:
    build: .
    command: ["./wait_for_postgres.sh", "db", "5432"]
    
    volumes:
      - .:/app
    ports:
      - "8000:8000"
    depends_on:
      - db
    environment:
      DEBUG: 'false'
      ALLOWED_HOSTS: "localhost 127.0.0.1"
      SQL_ENGINE: django.db.backends.postgresql
      SQL_DATABASE: notes_db
      SQL_USER: notes_user
      SQL_PASSWORD: notes_password
      SQL_HOST: db
      SQL_PORT: 5432

  db:
    image: postgres:16.3
    volumes:
      - db:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    environment:
      POSTGRES_DB: notes_db
      POSTGRES_USER: notes_user
      POSTGRES_PASSWORD: notes_password

volumes:
  db:
```

<br> <br> <br>

## فایل `Dockerfile`:

در این فایل، ابتدا از تصویر پایه python:3.9 استفاده می‌شود که شامل نسخه‌ای از زبان برنامه‌نویسی پایتون است. سپس، دایرکتوری کاری داخل کانتینر به /app تنظیم می‌شود تا تمام دستورات بعدی در این مسیر اجرا شوند. <br>
در ادامه، با اجرای دستور apt-get update، لیست بسته‌های موجود به‌روز می‌شود و سپس بسته netcat-openbsd نصب می‌گردد. این بسته برای بررسی وضعیت ارتباط با سرویس‌های شبکه مانند پایگاه داده استفاده می‌شود. پس از نصب بسته‌های مورد نیاز، تمام فایل‌های پروژه از دایرکتوری فعلی به مسیر /app در داخل کانتینر کپی می‌شوند. <br>
در مرحله بعد، با استفاده از دستور pip install، تمام کتابخانه‌های مورد نیاز پروژه که در فایل requirements.txt مشخص شده‌اند، بدون استفاده از کش قبلی نصب می‌شوند. این فرآیند تضمین می‌کند که تمامی وابستگی‌های پروژه به درستی نصب شده‌اند. <br>
سپس، پورت 8000 در کانتینر باز می‌شود تا وب‌سرور Django بتواند به درخواست‌های ورودی پاسخ دهد. همچنین، متغیر محیطی DJANGO_SETTINGS_MODULE تنظیم می‌شود تا Django از فایل تنظیمات صحیح استفاده کند. در نهایت، فرمان CMD مشخص می‌کند که وقتی کانتینر اجرا شد، سرور Django با استفاده از دستور python manage.py runserver بر روی پورت 8000 راه‌اندازی شود. <br> <br>
در زیر کد این فایل را مشاهده می‌کنید: <br> <br>

```Dockerfile
# Dockerfile

FROM python:3.9

WORKDIR /app

RUN apt-get update && apt-get install -y netcat-openbsd

COPY . /app

RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 8000

ENV DJANGO_SETTINGS_MODULE=notes.settings

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]

```
<br> <br> <br>


## فایل `requirements.txt`:

به این فایل صرفا یک خط `psycopg2-binary` اضافه شده است که این کتابخانه پایتون، یک درایور برای PostgreSQL است که ارتباط بین Django و پایگاه داده PostgreSQL را فراهم می‌کند. با اضافه کردن این کتابخانه به requirements.txt، اطمینان حاصل می‌کنیم که پروژه می‌تواند به پایگاه داده PostgreSQL متصل شود. <br> <br> <br>

## فایل `wait_for_postgres.sh`:

این اسکریپت bash که در فایل wait_for_postgres.sh نوشته شده است، به منظور اطمینان از برقرار بودن ارتباط با پایگاه داده PostgreSQL قبل از راه‌اندازی سرور Django طراحی شده است. اسکریپت با استفاده از گزینه set -e تنظیم می‌شود تا در صورت بروز هرگونه خطا در طول اجرای دستورات، فوراً متوقف شود و از ادامه اجرای اسکریپت جلوگیری کند. <br>
در ابتدای اسکریپت، مقادیر ورودی که شامل میزبان (host) و پورت (port) پایگاه داده هستند، دریافت می‌شوند. سپس، با استفاده از دستور shift 2، این مقادیر از لیست ورودی‌ها حذف می‌شوند تا دستور اصلی (cmd) که باید اجرا شود، در متغیرهای بعدی ذخیره شود. <br>
اسکریپت سپس با استفاده از یک حلقه while شروع به بررسی وضعیت پایگاه داده می‌کند. دستور nc -z یا netcat تلاش می‌کند تا ببیند آیا پورت مشخص شده در میزبان مورد نظر باز است و به درخواست‌ها پاسخ می‌دهد یا خیر. تا زمانی که ارتباط با پایگاه داده برقرار نشده، اسکریپت هر یک ثانیه یک بار بررسی را تکرار می‌کند. هنگامی که پایگاه داده قابل دسترسی شد، پیامی مبنی بر آماده بودن PostgreSQL چاپ می‌شود و اسکریپت به مرحله بعدی می‌رود. <br>
در این مرحله، اسکریپت با اجرای دستور python manage.py migrate مهاجرت‌های پایگاه داده را انجام می‌دهد. این فرآیند تمام تغییرات لازم در پایگاه داده را که در فایل‌های مهاجرت Django تعریف شده‌اند، اعمال می‌کند. پس از تکمیل موفقیت‌آمیز مهاجرت‌ها، پیامی مبنی بر اتمام مهاجرت‌ها چاپ می‌شود. <br>
در نهایت، اسکریپت با استفاده از دستور exec python manage.py runserver 0.0.0.0:8000 سرور Django را روی آدرس 0.0.0.0 و پورت 8000 راه‌اندازی می‌کند. دستور exec تضمین می‌کند که فرآیند runserver به عنوان فرآیند اصلی اجرا شود و اسکریپت تا زمانی که سرور فعال است به اجرا ادامه دهد. <br>
این اسکریپت به صورت خودکار ترتیب اجرای مهاجرت‌های پایگاه داده و راه‌اندازی سرور را مدیریت می‌کند و اطمینان حاصل می‌کند که پایگاه داده قبل از راه‌اندازی سرور کاملاً آماده است. <br> <br>

در زیر کد این فایل را مشاهده می‌کنید: <br> <br>
```bash
#!/bin/bash

set -e

host="$1"
port="$2"
shift 2
cmd="$@"

echo "Waiting for PostgreSQL at $host:$port..."

while ! nc -z "$host" "$port"; do
  sleep 1
done

echo "PostgreSQL is available - executing command"
# Run migrations and then start the server in the foreground
python manage.py migrate
echo "Migrations complete, starting server..."
exec python manage.py runserver 0.0.0.0:8000
```
<br> <br> <br>

## فایل `settings.py`:
```python
DEBUG = os.getenv('DEBUG', 'false').lower() == 'true'
```
قبل: مقدار DEBUG به صورت دستی در کد تعیین شده بود. <br>
بعد: مقدار DEBUG از متغیر محیطی DEBUG خوانده می‌شود. اگر این متغیر موجود نباشد، مقدار پیش‌فرض false استفاده می‌شود. سپس مقدار متغیر به صورت رشته‌ای تبدیل شده و بررسی می‌شود که آیا برابر با true است یا خیر. <br> <br>

```python
ALLOWED_HOSTS = os.getenv('ALLOWED_HOSTS').split()
```
قبل: ALLOWED_HOSTS به صورت دستی و به عنوان یک لیست خالی تعریف شده بود. <br>
بعد: مقدار ALLOWED_HOSTS از متغیر محیطی ALLOWED_HOSTS خوانده می‌شود. این مقدار به صورت یک رشته از متغیر محیطی گرفته شده و با استفاده از متد split() به یک لیست تبدیل می‌شود. این لیست شامل نام دامنه‌هایی است که اجازه دسترسی به برنامه را دارند. <br> <br>

```python
DATABASES = {
    'default': {
        'ENGINE': os.getenv('SQL_ENGINE', 'django.db.backends.postgresql'),
        'NAME': os.getenv('SQL_DATABASE'),
        'USER': os.getenv('SQL_USER'),
        'PASSWORD': os.getenv('SQL_PASSWORD'),
        'HOST': os.getenv('SQL_HOST'),
        'PORT': os.getenv('SQL_PORT', '5432'),
    }
}
```
قبل: تنظیمات پایگاه‌داده به صورت ثابت در کد تعریف شده بودند و از پایگاه‌داده SQLite استفاده می‌شد. <br>
بعد: اکنون تنظیمات پایگاه‌داده از متغیرهای محیطی خوانده می‌شوند. این تغییر باعث می‌شود که بتوانیم نوع پایگاه‌داده (مثل PostgreSQL)، نام پایگاه‌داده، کاربر، رمز عبور، هاست و پورت آن را از طریق متغیرهای محیطی تنظیم کنیم. <br> <br>

## اجرای پروژه

برای اجرای پروژه کافیست دستور زیر را اجرا کنید: <br> <br>
```sh
docker-compose up --build
```
<br> <br>


# تعامل با داکر

## بخش اول

در عکس زیر لیست تمامی imageها را مشاهده می‌کنید: <br> <br>
![image](https://github.com/user-attachments/assets/e2e0b6d7-03cc-40cc-aa4d-64c3f8322ccf)
<br> <br>


در عکس‌های زیر لیست تمامی کانتینرهای در حال اجرا و متوقف شده را مشاهده می‌کنید: <br> <br>
![image](https://github.com/user-attachments/assets/85fbd649-02a6-4947-9c06-2c00e5645771)
![image](https://github.com/user-attachments/assets/6195bb2f-caf0-4602-bfd6-4f52e9b6169b)
![image](https://github.com/user-attachments/assets/7240d1ee-5fae-4990-85b0-8c5388d38bcf)
<br> <br>

آ‌ن‌هایی که مربوط به این آزمایش هستند `test-web` و `az5_main-web` و `postgres:16.3` هستند.<br> <br>


## بخش دوم

برای اجرای دستوری در داخل یک کانتینر وب‌سرور، ابتدا باید ID یا نام کانتینر مربوطه را پیدا کرده و سپس از دستور docker exec استفاده کنیم. به عنوان مثال، می‌توانیم یک دستور ساده مانند ls برای لیست کردن فایل‌ها در داخل کانتینر وب‌سرور اجرا کنیم. در تصویر زیر عکس دستور اجرار شده را مشاهده می‌کنید: <br> <br>
![image](https://github.com/user-attachments/assets/7d68ba60-d591-4dd4-82a4-1c67ce7dccfe)
<br> <br> <br>


# پرسش ها 

## سوال 1

### توضیح Dockerfile:
درواقع Dockerfile یک فایل متنی است که حاوی دستورالعمل‌هایی برای ساخت یک Docker Image است. این فایل مانند کد منبع برای تصویر عمل می‌کند و مراحل لازم برای ایجاد تصویر را تعریف می‌کند. دستورالعمل‌های رایج در Dockerfile شامل `FROM` برای تعیین تصویر پایه، `RUN` برای نصب وابستگی‌ها، `COPY` برای کپی کردن فایل‌ها و `CMD` برای تعیین دستور پیش‌فرضی است که هنگام اجرای کانتینر اجرا می‌شود. Dockerfile به اتوماسیون فرآیند ساخت و اطمینان از سازگاری محیط‌ها کمک می‌کند.
<br>

### توضیح Docker Image:
و Docker Image  یک قالب فقط خواندنی است که شامل دستورالعمل‌های لازم برای ایجاد یک Docker Container است. این تصویر مانند نقشه‌ای برای کانتینر عمل می‌کند و شامل کد برنامه، کتابخانه‌ها، ابزارها، وابستگی‌ها و سایر فایل‌های مورد نیاز برای اجرای برنامه می‌شود. تصاویر Docker با استفاده از Dockerfile ساخته می‌شوند و می‌توانند برای اشتراک‌گذاری و استفاده مجدد در یک ریپازیتوری ذخیره شوند. تصاویر Docker از چندین لایه تشکیل شده‌اند که هر کدام نمایانگر یک تغییر در تصویر هستند، این ساختار لایه‌ای باعث کاهش حجم تصویر و افزایش کارایی در اشتراک‌گذاری می‌شود.



### توضیح Docker Container:
و در نهایت Docker Container  یک نمونه در حال اجرای یک Docker Image است. کانتینر یک محیط اجرایی برای برنامه فراهم می‌کند و شامل یک لایه نوشتنی بالای لایه‌های فقط خواندنی تصویر است. کانتینرها از تصاویر ساخته می‌شوند و می‌توانند به صورت مستقل مدیریت شوند، مثلاً می‌توان آن‌ها را شروع، متوقف و مدیریت کرد. کانتینرها ایزوله‌سازی و قابلیت حمل بالایی ارائه می‌دهند که به برنامه‌ها اجازه می‌دهد به صورت یکسان در محیط‌های مختلف اجرا شوند.


