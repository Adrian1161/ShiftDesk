# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

## Business registration and invitations

An owner can register a business from the home page, then invite employees from the business page. Invitees receive a link that expires after seven days and can join with a new account or their existing ShiftDesk password.

To send invitations, set `SMTP_HOST`, `SMTP_PORT`, `SMTP_USER`, `SMTP_PASSWORD`, `MAIL_FROM`, and `APP_HOST` (the public hostname). In development without SMTP, emails are written to `tmp/mails` instead of being sent.
