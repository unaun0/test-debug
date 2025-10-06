-- Удаление всех отношений

DROP TABLE IF EXISTS "Attendance";
DROP TABLE IF EXISTS "Training";
DROP TABLE IF EXISTS "Membership";
DROP TABLE IF EXISTS "TrainingRoom";
DROP TABLE IF EXISTS "MembershipType";
DROP TABLE IF EXISTS "Trainer";
DROP TABLE IF EXISTS "User";

-- Создание отношений

-- Пользователь
CREATE TABLE "User" (
    id                 UUID,
    email             TEXT,
    phone_number     TEXT,
    "password"         TEXT,
    first_name         TEXT,
    last_name         TEXT,
    gender             TEXT,
    birth_date         DATE,
    "role"             TEXT
);

-- Тренер
CREATE TABLE "Trainer" (
    id                 UUID,
    user_id            UUID,
    description     TEXT
);

-- Тип абонемента
CREATE TABLE "MembershipType" (
    id             UUID,
    name         TEXT,
    price         NUMERIC,
    sessions    INT,
    days        INT
);

-- Зал для тренировок
CREATE TABLE "TrainingRoom" (
    id            UUID,
    name         TEXT,
    capacity     INT
);

-- Абонемент
CREATE TABLE "Membership" (
    id                     UUID,
    user_id                UUID,
    membership_type_id    UUID,
    start_date            DATE,
    end_date            DATE,
    available_sessions    INT
);

-- Тренировка
CREATE TABLE "Training" (
    id                     UUID,
    room_id                UUID,
    trainer_id            UUID,
    "date"                TIMESTAMP
);

-- Посещение
CREATE TABLE "Attendance" (
    id                 UUID,
    membership_id    UUID,
    training_id        UUID,
    status            TEXT
);


-- Создание ограничений целостности данных

-- Пользователь
ALTER TABLE "User"
	-- id
    ADD CONSTRAINT "pk:user.id" PRIMARY KEY (id),
    ALTER COLUMN id SET DEFAULT gen_random_uuid(),
	-- email
    ADD CONSTRAINT "chk:user.email:notnull" CHECK (
		email IS NOT NULL
	),
	ADD CONSTRAINT "chk:user.email:length" CHECK (
		length(email) < 128
	),
	ADD CONSTRAINT "chk:user.email:regexp" CHECK (
		email ~ '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$'
	),
	ADD CONSTRAINT "uq:user.email" UNIQUE (email),
	-- phone_number
	ADD CONSTRAINT "chk:user.phone_number:notnull" CHECK (
		phone_number IS NOT NULL
	),
	ADD CONSTRAINT "chk:user.phone_number:length" CHECK (
		length(phone_number) < 32
	),
	ADD CONSTRAINT "chk:user.phone_number:regexp" CHECK (
		phone_number ~ '^\+\d{10,15}$'
	),
	ADD CONSTRAINT "uq:user.phone_number" UNIQUE (phone_number),
	-- password
    ADD CONSTRAINT "chk:user.password:notnull" CHECK (
		"password" IS NOT NULL
	),
	-- first_name
    ADD CONSTRAINT "chk:user.first_name:notnull" CHECK (
		first_name IS NOT NULL
	),
	ADD CONSTRAINT "chk:user.first_name:length" CHECK (
		length(first_name) < 128
	),
	ADD CONSTRAINT "chk:user.first_name:regexp" CHECK (
		first_name ~ '^([a-zA-Zа-яА-ЯёЁ]+(?:-[a-zA-Zа-яА-ЯёЁ]+)?)$'
	),
	-- last_name
    ADD CONSTRAINT "chk:user.last_name:notnull" CHECK (
		last_name IS NOT NULL
	),
	ADD CONSTRAINT "chk:user.last_name:length" CHECK (
		length(last_name) < 128
	),
	ADD CONSTRAINT "chk:user.last_name:regexp" CHECK (
		last_name ~ '^([a-zA-Zа-яА-ЯёЁ]+(?:-[a-zA-Zа-яА-ЯёЁ]+)?)$'
	),
	-- gender
    ADD CONSTRAINT "chk:user.gender:notnull" CHECK (
		gender IS NOT NULL
	),
	ADD CONSTRAINT "chk:user.gender:length" CHECK (
		length(gender) < 32
	),
	ADD CONSTRAINT "chk:user.gender:regexp" CHECK (
		gender IN ('мужской', 'женский')
	),
	-- birth_date
    ADD CONSTRAINT "chk:user.birth_date:notnull" CHECK (
		birth_date IS NOT NULL
	),
	ADD CONSTRAINT "chk:user.birth_date" CHECK (
	    birth_date >= CURRENT_DATE - INTERVAL '120 years' AND
	    birth_date <= CURRENT_DATE - INTERVAL '14 years'
	),
	-- role
	ADD CONSTRAINT "chk:user.role:notnull" CHECK (
		"role" IS NOT NULL
	),
	ADD CONSTRAINT "chk:user.role:length" CHECK (
		length("role") < 32
	),
	ADD CONSTRAINT "chk:user.role:regexp" CHECK (
        "role" IN ('клиент', 'тренер', 'администратор')
    );

-- Тренер
ALTER TABLE "Trainer"
	-- id
	ADD CONSTRAINT "pk:trainer.id" PRIMARY KEY (id),
    ALTER COLUMN id SET DEFAULT gen_random_uuid(),
	-- user_id
    ADD CONSTRAINT "fk:trainer.user_id" FOREIGN KEY (user_id) 
        REFERENCES "User"(id) ON DELETE CASCADE,
    ADD CONSTRAINT "uq:trainer.user_id" UNIQUE (user_id),
	-- description
	ALTER COLUMN "description" SET DEFAULT 'Нет описания.',
	ADD CONSTRAINT "chk:trainer.description:notnull" CHECK (
		description IS NOT NULL
	),
	ADD CONSTRAINT "chk:trainer.description:length" CHECK (
		length(description) < 512
	);

-- Тип абонемента
ALTER TABLE "MembershipType"
	-- id
	ADD CONSTRAINT "pk:membership_type.id" PRIMARY KEY (id),
    ALTER COLUMN id SET DEFAULT gen_random_uuid(),
	-- name
	ADD CONSTRAINT "chk:membership_type.name:notnull" CHECK (
		name IS NOT NULL
	),
    ADD CONSTRAINT "chk:membership_type.name:length" CHECK (
		length(name) < 128
	),
	ADD CONSTRAINT "uq:membership_type.name" UNIQUE (name),
	-- price
	ALTER COLUMN price SET DEFAULT 0.0,
	ADD CONSTRAINT "chk:membership_type.price:notnull" CHECK (
		price IS NOT NULL
	),
    ADD CONSTRAINT "chk:membership_type.price:unsigned" CHECK (
		price >= 0.0
	),
	-- sessions
	ALTER COLUMN sessions SET DEFAULT 1,
	ADD CONSTRAINT "chk:membership_type.sessions:notnull" CHECK (
		sessions IS NOT NULL
	),
    ADD CONSTRAINT "chk:membership_type.sessions:unsigned" CHECK (
		sessions > 0
	),
	-- days
	ALTER COLUMN days SET DEFAULT 1,
	ADD CONSTRAINT "chk:membership_type.days:notnull" CHECK (
		days IS NOT NULL
	),
    ADD CONSTRAINT "chk:membership_type.days:unsigned" CHECK (
		days > 0
	);

-- Зал для тренировок
ALTER TABLE "TrainingRoom"
	-- id
	ADD CONSTRAINT "pk:training_room.id" PRIMARY KEY (id),
    ALTER COLUMN id SET DEFAULT gen_random_uuid(),
	-- name
	ADD CONSTRAINT "chk:training_room.name:notnull" CHECK (
		name IS NOT NULL
	),
    ADD CONSTRAINT "chk:training_room.name:length" CHECK (
		length(name) < 64
	),
	ADD CONSTRAINT "uq:training_room.name" UNIQUE (name),
	-- capacity
	ADD CONSTRAINT "chk:training_room.capacity:notnull" CHECK (
		capacity IS NOT NULL
	),
    ADD CONSTRAINT "chk:training_room.capacity" CHECK (capacity > 0);

-- Абонемент
ALTER TABLE "Membership"
	-- id
	ADD CONSTRAINT "pk:membership.id" PRIMARY KEY (id),
    ALTER COLUMN id SET DEFAULT gen_random_uuid(),
	-- user_id
	ADD CONSTRAINT "fk:membership.user_id" FOREIGN KEY (user_id) 
		REFERENCES "User"(id) ON DELETE CASCADE,
	-- membership_type_id
	ADD CONSTRAINT "fk:membership.membership_type_id" 
		FOREIGN KEY (membership_type_id) 
		REFERENCES "MembershipType"(id) ON DELETE SET NULL,
	ADD CONSTRAINT "uq:membership.membership_type+user"
		UNIQUE(membership_type_id, user_id),
	-- start_date
	ALTER COLUMN start_date SET DEFAULT NULL,
	-- end_date
	ALTER COLUMN end_date SET DEFAULT NULL,
	ADD CONSTRAINT "chk:membership.dates:order" CHECK (
    	(start_date IS NULL AND end_date IS NULL) 
		OR (
			start_date IS NOT NULL and end_date IS NOT NULL 
			AND start_date <= end_date
		)
	),
	-- available_sessions
	ALTER COLUMN available_sessions SET DEFAULT 0,
	ADD CONSTRAINT "chk:membership.available_sessions:notnull" CHECK (
		available_sessions IS NOT NULL
	),
    ADD CONSTRAINT "chk:membership.available_sessions:unsigned" CHECK (
		available_sessions >= 0
	);

-- Тренировка
ALTER TABLE "Training"
	-- id 
	ADD CONSTRAINT "pk:training.id" PRIMARY KEY (id),
    ALTER COLUMN id SET DEFAULT gen_random_uuid(),
	-- room_id
	ADD CONSTRAINT "fk:training.room_id" 
		FOREIGN KEY (room_id) 
		REFERENCES "TrainingRoom"(id) ON DELETE SET NULL,
	-- trainer_id
	ADD CONSTRAINT "fk:training.trainer_id" 
		FOREIGN KEY (trainer_id) 
		REFERENCES "Trainer"(id) ON DELETE SET NULL,
	-- date
	ALTER COLUMN "date" SET DEFAULT CURRENT_TIMESTAMP,
	ADD CONSTRAINT "chk:training.date:notnull" CHECK (
		"date" IS NOT NULL
	);

-- Посещение
ALTER TABLE "Attendance"
	-- id 
	ADD CONSTRAINT "pk:attendance.id" PRIMARY KEY (id),
    ALTER COLUMN id SET DEFAULT gen_random_uuid(),
	-- membership_id
	ADD CONSTRAINT "fk:attendance.membership_id" 
		FOREIGN KEY (membership_id) 
		REFERENCES "Membership"(id) ON DELETE CASCADE,
	-- training_id
	ADD CONSTRAINT "fk:attendance.training_id" 
		FOREIGN KEY (training_id) 
		REFERENCES "Training"(id) ON DELETE SET NULL,
	ADD CONSTRAINT "uq:attendance.membership+training" 
		UNIQUE (membership_id, training_id),
	-- status
	ALTER COLUMN status SET DEFAULT 'ожидает',
	ADD CONSTRAINT "chk:attendance.status:notnull" CHECK (
		status IS NOT NULL
	),
	ADD CONSTRAINT "chk:attendance.status:length" CHECK (
		length(status) < 64
	),
    ADD CONSTRAINT "chk:attendance.status:regexp" CHECK (
		status IN ('посетил', 'отсутствовал', 'ожидает')
	);



