create
    definer = openmrs@`%` procedure CreateMultipleUsers(IN numberOfUsers int)
BEGIN
    DECLARE counter INT DEFAULT 0;
    WHILE counter < numberOfUsers DO
        -- Inserting random data into 'person' table
        INSERT INTO openmrs.person (
            gender, birthdate, birthdate_estimated, dead, death_date, cause_of_death,
            creator, date_created, changed_by, date_changed, voided, voided_by,
            date_voided, void_reason, uuid, deathdate_estimated, birthtime, cause_of_death_non_coded
        )
        VALUES (
            'M', -- Gender (assuming Male)
            DATE_SUB(NOW(), INTERVAL 30 YEAR), -- Birthdate around 30 years ago
            0, 0, NULL, NULL,
            1, NOW(), 2, NOW(), 0, NULL,
            NULL, NULL, UUID(), 0, NULL, NULL
        );

        -- Retrieve the last inserted person_id
        SET @lastPersonID := (SELECT MAX(person_id) FROM openmrs.person);

        -- Inserting user using person_id
        INSERT INTO openmrs.users (
            system_id, username, password, salt, secret_question, secret_answer,
            creator, date_created, changed_by, date_changed, person_id,
            retired, retired_by, date_retired, retire_reason, uuid, activation_key, email
        )
        VALUES (
            CONCAT('user-test-', @lastPersonID), CONCAT('user-test-', @lastPersonID),
            '6f0be51d599f59dd1269e12e17949f8ecb9ac963e467ac1400cf0a02eb9f8861ce3cca8f6d34d93c0ca34029497542cbadda20c949affb4cb59269ef4912087b',
            'c788c6ad82a157b712392ca695dfcf2eed193d7f', NULL, NULL,
            1, '2005-01-01 00:00:00', 1, '2023-11-13 10:54:24', @lastPersonID,
            0, NULL, NULL, NULL, UUID(), NULL, NULL
        );

        SET @lastUserID := (SELECT MAX(user_id) FROM openmrs.users);

        -- Inserting data into 'user_role' for the last inserted user
        INSERT INTO openmrs.user_role (user_id, `role`)
        VALUES (
            @lastUserID, -- Use the last inserted user_id
            'Privilege Level: Doctor'
        );

        -- Inserting data into 'user_property' for the last inserted user
        INSERT INTO openmrs.user_property (user_id, property, property_value)
        VALUES (
            @lastUserID, -- Use the last inserted user_id
            'locationUuid',
            '8d6c993e-c2cc-11de-8d13-0010c6dffd0f'
        );

        SET counter = counter + 1;
    END WHILE;
END;


