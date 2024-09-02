-- Keep a log of any SQL queries you execute as you solve the mystery.

-- prompting for all tables available
.table

-- visualize create table commands
.schema

-- query crime scene reports table
SELECT * FROM crime_scene_reports;

-- query for description of crimes on place and day especified
SELECT description
FROM crime_scene_reports
WHERE month = 7 AND day = 28 AND street = 'Humphrey Street';
-- Theft of the CS50 duck took place at 10:15am at the Humphrey Street bakery. Interviews were conducted today with three witnesses
-- who were present at the time – each of their interview transcripts mentions the bakery.

-- query interviews on day that the crime took place
SELECT name, transcript
FROM interviews
WHERE year = 2021 AND month = 7 AND day = 28;
-- Ruth: Sometime within ten minutes of the theft, I saw the thief get into a car in the bakery parking lot and drive away.
-- If you have security footage from the bakery parking lot, you might want to look for cars that left the parking lot in that time frame. -> 10:20 - 10:35
    -- check bakery security logs
    SELECT license_plate, minute
    FROM bakery_security_logs
    WHERE year = 2021 AND month = 7 AND day = 28 AND hour = 10 AND minute >= 15 AND minute <= 25 AND activity = 'exit';
    --  5P2BI95       | 16     |
    -- | 94KL13X       | 18     |
    -- | 6P58WS2       | 18     |
    -- | 4328GD8       | 19     |
    -- | G412CB7       | 20     |
    -- | L93JTIZ       | 21     |
    -- | 322W7JE       | 23     |
    -- | 0NTHK55       | 23     |
    -- query people table for suspects by license_plate
    SELECT name
    FROM people
    WHERE license_plate IN (
    SELECT license_plate
    FROM bakery_security_logs
    WHERE year = 2021 AND month = 7 AND day = 28 AND hour = 10 AND minute >= 15 AND minute <= 25 AND activity = 'exit');
    -- | Vanessa |
    -- | Barry   |
    -- | Iman    |
    -- | Sofia   |
    -- | Luca    |
    -- | Diana   |
    -- | Kelsey  |
    -- | Bruce   |
-- Eugene: I don't know the thief's name, but it was someone I recognized. Earlier this morning, before I arrived at Emma's bakery,
-- I was walking by the ATM on Leggett Street and saw the thief there withdrawing some money.
    -- query atm transactions table for account_number
    SELECT account_number
    FROM atm_transactions
    WHERE atm_location = 'Leggett Street' AND day = 28 AND month = 7 AND year = 2021 AND transaction_type = 'withdraw';
    -- query bank accounts table for person_id
    SELECT person_id
    FROM bank_accounts
    WHERE account_number IN (
    SELECT account_number
    FROM atm_transactions
    WHERE atm_location = 'Leggett Street' AND day = 28 AND month = 7 AND year = 2021 AND transaction_type = 'withdraw');
    -- query people table for suspects by account_number
    SELECT name
    FROM people
    WHERE id IN (
    SELECT person_id
    FROM bank_accounts
    WHERE account_number IN (
    SELECT account_number
    FROM atm_transactions
    WHERE atm_location = 'Leggett Street' AND day = 28 AND month = 7 AND year = 2021 AND transaction_type = 'withdraw'));
    -- | Kenny   |
    -- | Iman    |
    -- | Benista |
    -- | Taylor  |
    -- | Brooke  |
    -- | Luca    |
    -- | Diana   |
    -- | Bruce   |
-- Raymond: As the thief was leaving the bakery, they called someone who talked to them for less than a minute. In the call, I heard the thief say that they
-- were planning to take the earliest flight out of Fiftyville tomorrow. The thief then asked the person on the other end of the phone to purchase the flight ticket.
    -- query phone_calls table
    SELECT caller, receiver, duration
    FROM phone_calls
    WHERE year = 2021 AND month = 7 AND day = 28 AND duration < 60;
    -- query people for suspects by phone_number
    SELECT name
    FROM people
    WHERE phone_number IN (
    SELECT caller
    FROM phone_calls
    WHERE year = 2021 AND month = 7 AND day = 28 AND duration < 60);
    -- | Kenny   |
    -- | Sofia   |
    -- | Benista |
    -- | Taylor  |
    -- | Diana   |
    -- | Kelsey  |
    -- | Bruce   |
    -- | Carina  |
    -- query table of airports for origin
    SELECT id, abbreviation, full_name
    FROM airports
    WHERE city = 'Fiftyville';
    -- id: 8
    -- query table of flights
    SELECT destination_airport_id, hour, minute
    FROM flights
    WHERE  year = 2021 AND month = 7 AND day = 29 AND origin_airport_id = 8;
    -- id: 4
    -- query table of airports for destination
    SELECT city
    FROM airports
    WHERE id = 4;
    -- New York City
    -- query for flight_id
    SELECT id
    FROM flights
    WHERE destination_airport_id = 4 AND origin_airport_id = 8 AND year = 2021 AND month = 7 AND day = 29;
    -- query passengers table for passport number
    SELECT passport_number
    FROM passengers
    WHERE flight_id IN (
    SELECT id
    FROM flights
    WHERE destination_airport_id = 4 AND origin_airport_id = 8 AND year = 2021 AND month = 7 AND day = 29);
    -- query people table for suspects by passport_number
    SELECT name
    FROM people
    WHERE passport_number IN (
    SELECT passport_number
    FROM passengers
    WHERE flight_id IN (
    SELECT id
    FROM flights
    WHERE destination_airport_id = 4 AND origin_airport_id = 8 AND year = 2021 AND month = 7 AND day = 29));
    -- | Kenny  |
    -- | Sofia  |
    -- | Taylor |
    -- | Luca   |
    -- | Kelsey |
    -- | Edward |
    -- | Bruce  |
    -- | Doris  |
    -- crossing lists of suspects, Bruce is the thief
    -- getting suspects number
    SELECT phone_number
    FROM people
    WHERE name = 'Bruce';
    -- getting the receiver from Taylor's call
    SELECT receiver
    FROM phone_calls
    WHERE year = 2021 AND month = 7 AND day = 28 AND duration < 60 AND caller IN (
    SELECT phone_number
    FROM people
    WHERE name = 'Bruce');
    -- getting the partner's name
    SELECT name
    FROM people
    WHERE phone_number IN (
    SELECT receiver
    FROM phone_calls
    WHERE year = 2021 AND month = 7 AND day = 28 AND duration < 60 AND caller IN (
    SELECT phone_number
    FROM people
    WHERE name = 'Bruce'));
