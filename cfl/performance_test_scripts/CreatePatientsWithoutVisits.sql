create
    definer = openmrs@`%` procedure CreatePatientsWithoutVisists(IN numPatients int)
BEGIN
    DECLARE counter INT DEFAULT 0;

    WHILE counter < numPatients DO

-- Inserting random data into 'person' table
INSERT INTO openmrs.person (gender, birthdate, birthdate_estimated, dead, death_date, cause_of_death, creator, date_created, changed_by, date_changed, voided, voided_by, date_voided, void_reason, uuid, deathdate_estimated, birthtime, cause_of_death_non_coded)
VALUES (
    'M', -- Gender (assuming Male)
    DATE_SUB(NOW(), INTERVAL 30 YEAR), -- Birthdate around 30 years ago
    0, -- birthdate_estimated
    0, -- Not dead
    NULL, -- No death date
    NULL, -- No cause of death
    1, -- Creator ID
    NOW(), -- Current date
    2, -- Changed_by ID
    NOW(), -- Current date
    0, -- Not voided
    NULL,
    NULL,
    NULL,
    UUID(), -- UUID
    0, -- deathdate_estimated
    NULL,
    NULL
);

-- Retrieve the last inserted person_id
SET @lastPersonID := (SELECT MAX(person_id) FROM openmrs.person);

-- Inserting patient data based on person data
INSERT INTO openmrs.patient (patient_id, creator, date_created, changed_by, date_changed, voided, voided_by, date_voided, void_reason, allergy_status)
VALUES (
    @lastPersonID, -- person_id will be the same as patient_id
    1, -- Creator ID
    NOW(), -- Current date
    2, -- Changed_by ID
    NOW(), -- Current date
    0, -- Not voided
    NULL,
    NULL,
    NULL,
    'Unknown'
);

-- Inserting data into 'patient_identifier' for the last inserted patient
INSERT INTO openmrs.patient_identifier (patient_id, identifier, identifier_type, preferred, location_id, creator, date_created, uuid, voided)
VALUES (
    @lastPersonID, -- Use the last inserted person_id as patient_id
    LPAD(FLOOR(RAND() * 1000000), 6, '0'), -- Random six-digit number
    4, -- Identifier type (assuming 4)
    1, -- Preferred
    1, -- Location ID
    1, -- Creator ID
    NOW(), -- Current date
    UUID(), -- UUID
    0 -- Not voided
);



-- Inserting data into 'person_attribute' for the last inserted person (patient)
-- Inserting LocationAttribute
INSERT INTO openmrs.person_attribute (person_id, value, person_attribute_type_id, creator, date_created, uuid, voided)
VALUES (
    @lastPersonID, -- Use the last inserted person_id
    '8d6c993e-c2cc-11de-8d13-0010c6dffd0f', -- LocationAttribute value
    8, -- Attribute type ID
    1, -- Creator ID
    NOW(), -- Current date
    UUID(), -- UUID,
    0 -- Not voided
);

-- Inserting Person status (ACTIVATED)
INSERT INTO openmrs.person_attribute (person_id, value, person_attribute_type_id, creator, date_created, uuid, voided)
VALUES (
    @lastPersonID, -- Use the last inserted person_id
    'ACTIVATED', -- Person status value
    11, -- Attribute type ID
    1, -- Creator ID
    NOW(), -- Current date
    UUID(), -- UUID
    0 -- Not voided
);

-- Inserting Telephone Number (random format: '+48 XXX XXX XXX X')
INSERT INTO openmrs.person_attribute (person_id, value, person_attribute_type_id, creator, date_created, uuid, voided)
VALUES (
    @lastPersonID, -- Use the last inserted person_id
    CONCAT(
        '48',
        FLOOR(RAND() * 900) + 100,
        FLOOR(RAND() * 900) + 100,
        FLOOR(RAND() * 9000) + 1000,
        FLOOR(RAND() * 10)
    ),
    14, -- Attribute type ID
    1, -- Creator ID
    NOW(), -- Current date
    UUID(), -- UUID
    0 -- Not voided
);

-- Inserting personLanguage (English)
INSERT INTO openmrs.person_attribute (person_id, value, person_attribute_type_id, creator, date_created, uuid, voided)
VALUES (
    @lastPersonID, -- Use the last inserted person_id
    'English', -- personLanguage value
    16, -- Attribute type ID
    1, -- Creator ID
    NOW(), -- Current date
    UUID(), -- UUID
    0 -- Not voided
);

-- Inserting Person Names with Test Names and Surnames
INSERT INTO openmrs.person_name (
    preferred, person_id, prefix, given_name, middle_name, family_name_prefix, family_name, family_name2,
    family_name_suffix, `degree`, creator, date_created, voided, voided_by, date_voided, void_reason,
    changed_by, date_changed, uuid
) VALUES (
    1, @lastPersonID, NULL,
    CONCAT('Test-', @lastPersonID), -- Test names based on person ID
    NULL, NULL,
    CONCAT('Test-', @lastPersonID), -- Test surnames based on person ID
    NULL, NULL, NULL, 1, NOW(), 0, NULL, NULL, NULL, NULL, NOW(), UUID()
);


INSERT INTO openmrs.person_address (
    person_id, preferred, address1, address2, city_village, state_province, postal_code, country, latitude,
    longitude, start_date, end_date, creator, date_created, voided, voided_by, date_voided, void_reason,
    county_district, address3, address4, address5, address6, date_changed, changed_by, uuid
) VALUES (
    @lastPersonID,
    1,
    'Test Address Line 1',
    'Test Address Line 2',
    'Warsaw',
    'Warsaw',
    '00-001',
    'Poland',
    NULL,
    NULL,
    NOW(),
    NULL,
    1,
    NOW(),
    0,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NOW(),
    1,
    UUID()
);


        SET counter = counter + 1;
    END WHILE;
END;


