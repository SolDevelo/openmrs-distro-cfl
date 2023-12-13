create
    definer = openmrs@`%` procedure CreatePatientsWithDefaultVisitDistributionCall(IN numPatients int, IN numVisits int)
BEGIN
    DECLARE counter INT DEFAULT 0;

    WHILE counter < numPatients
        DO

            -- Inserting random data into 'person' table
            INSERT INTO openmrs.person (gender, birthdate, birthdate_estimated, dead, death_date,
                                                 cause_of_death,
                                                 creator, date_created, changed_by, date_changed, voided, voided_by,
                                                 date_voided,
                                                 void_reason, uuid, deathdate_estimated, birthtime,
                                                 cause_of_death_non_coded)
            VALUES ('M', -- Gender (assuming Male)
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
                    NULL);

-- Retrieve the last inserted person_id
            SET @lastPersonID := (SELECT MAX(person_id) FROM openmrs.person);

-- Inserting patient data based on person data
            INSERT INTO openmrs.patient (patient_id, creator, date_created, changed_by, date_changed, voided,
                                                  voided_by,
                                                  date_voided, void_reason, allergy_status)
            VALUES (@lastPersonID, -- person_id will be the same as patient_id
                    1, -- Creator ID
                    NOW(), -- Current date
                    2, -- Changed_by ID
                    NOW(), -- Current date
                    0, -- Not voided
                    NULL,
                    NULL,
                    NULL,
                    'Unknown');

-- Inserting data into 'patient_identifier' for the last inserted patient
            INSERT INTO openmrs.patient_identifier (patient_id, identifier, identifier_type, preferred,
                                                             location_id,
                                                             creator, date_created, uuid, voided)
            VALUES (@lastPersonID, -- Use the last inserted person_id as patient_id
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
            INSERT INTO openmrs.person_attribute (person_id, value, person_attribute_type_id, creator,
                                                           date_created,
                                                           uuid, voided)
            VALUES (@lastPersonID, -- Use the last inserted person_id
                    '8d6c993e-c2cc-11de-8d13-0010c6dffd0f', -- LocationAttribute value
                    8, -- Attribute type ID
                    1, -- Creator ID
                    NOW(), -- Current date
                    UUID(), -- UUID,
                    0 -- Not voided
                   );

-- Inserting Person status (ACTIVATED)
            INSERT INTO openmrs.person_attribute (person_id, value, person_attribute_type_id, creator,
                                                           date_created,
                                                           uuid, voided)
            VALUES (@lastPersonID, -- Use the last inserted person_id
                    'ACTIVATED', -- Person status value
                    11, -- Attribute type ID
                    1, -- Creator ID
                    NOW(), -- Current date
                    UUID(), -- UUID
                    0 -- Not voided
                   );

-- Inserting Telephone Number (random format: '+48 XXX XXX XXX X')
            INSERT INTO openmrs.person_attribute (person_id, value, person_attribute_type_id, creator,
                                                           date_created,
                                                           uuid, voided)
            VALUES (@lastPersonID, -- Use the last inserted person_id
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
            INSERT INTO openmrs.person_attribute (person_id, value, person_attribute_type_id, creator,
                                                           date_created,
                                                           uuid, voided)
            VALUES (@lastPersonID, -- Use the last inserted person_id
                    'English', -- personLanguage value
                    16, -- Attribute type ID
                    1, -- Creator ID
                    NOW(), -- Current date
                    UUID(), -- UUID
                    0 -- Not voided
                   );

-- Inserting Person Names with Test Names and Surnames
            INSERT INTO openmrs.person_name (preferred, person_id, prefix, given_name, middle_name,
                                                      family_name_prefix,
                                                      family_name, family_name2,
                                                      family_name_suffix, `degree`, creator, date_created, voided,
                                                      voided_by,
                                                      date_voided, void_reason,
                                                      changed_by, date_changed, uuid)
            VALUES (1, @lastPersonID, NULL,
                    CONCAT('Test-', @lastPersonID), -- Test names based on person ID
                    NULL, NULL,
                    CONCAT('Test-', @lastPersonID), -- Test surnames based on person ID
                    NULL, NULL, NULL, 1, NOW(), 0, NULL, NULL, NULL, NULL, NOW(), UUID());


            INSERT INTO openmrs.person_address (person_id, preferred, address1, address2, city_village,
                                                         state_province,
                                                         postal_code, country, latitude,
                                                         longitude, start_date, end_date, creator, date_created, voided,
                                                         voided_by, date_voided, void_reason,
                                                         county_district, address3, address4, address5, address6,
                                                         date_changed,
                                                         changed_by, uuid)
            VALUES (@lastPersonID,
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
                    UUID());


-- Box-Muller transform to generate standard normally distributed random numbers
            SET @u1 = RAND();
            SET @u2 = RAND();
            SET @z0 = SQRT(-2 * LOG(@u1)) * COS(2 * PI() * @u2);
            SET @meanHour = 15;
            SET @stdDevHour = 1; -- Standard deviation for the normal distribution
            SET @randomHour = ROUND(@meanHour + @stdDevHour * @z0, 1);
            -- Round to one decimal place

-- Ensure the generated hour is within the desired range (02:00 to 10:00)
            SET @randomHour = CASE
                                  WHEN @randomHour < 2 THEN 2
                                  WHEN @randomHour > 10 THEN 10
                                  ELSE @randomHour
                END;

-- Ensure the generated hour is rounded to the nearest half-hour
            SET @roundedHour = ROUND(@randomHour * 2) / 2;

-- Convert the rounded hour to minutes
            SET @randomMinutes = @roundedHour * 60;

-- Add the random minutes to the current date
            SET @visitDate = DATE_ADD(CURDATE(), INTERVAL 1 DAY) +
                             INTERVAL @randomMinutes MINUTE;

            IF counter < numVisits THEN
-- Inserting Visits for Patients
                INSERT INTO openmrs.visit (patient_id, visit_type_id, date_started, date_stopped,
                                                    indication_concept_id, location_id, creator, date_created,
                                                    changed_by, date_changed, voided, voided_by, date_voided,
                                                    void_reason, uuid)
                VALUES (@lastPersonID, -- Use the last inserted person_id as patient_id
                        1, -- Assuming visit type ID 1 for Follow-up
                        @visitDate,
                        NULL, -- No stop date
                        NULL, -- Indication concept ID
                        1, -- Location ID
                        1, -- Creator ID
                        '2023-11-13 13:42:24', -- Date created
                        NULL, NULL, 0, NULL, NULL, NULL, UUID());

-- Fetch the last inserted visit ID
                SET @lastVisitID = LAST_INSERT_ID();

-- Inserting Visit Attributes
                INSERT INTO openmrs.visit_attribute (visit_id, attribute_type_id, value_reference, uuid,
                                                              creator, date_created, changed_by, date_changed,
                                                              voided, voided_by, date_voided, void_reason)
                VALUES (@lastVisitID, -- Use the last inserted visit_id
                        2, -- Visit Status attribute_type_id
                        'SCHEDULED', -- Visit Status value_reference
                        UUID(), -- UUID
                        1, '2023-11-13 13:42:24', NULL, NULL, 0, NULL, NULL, NULL),
                       (@lastVisitID, -- Use the last inserted visit_id
                        1, -- Visit Time attribute_type_id
                        'Evening', -- Visit Time value_reference
                        UUID(), -- UUID
                        1, '2023-11-13 13:42:24', NULL, NULL, 0, NULL, NULL, NULL);
            END IF;


-- Inserting best contact time
            INSERT INTO openmrs.person_attribute (person_id, value, person_attribute_type_id, creator,
                                                           date_created, uuid, voided)
            VALUES (@lastPersonID, -- Use the last inserted person_id
                    TIME(@visitDate),
                    10, -- Attribute type ID
                    1, -- Creator ID
                    NOW(), -- Current date
                    UUID(), -- UUID
                    0 -- Not voided
                   );


-- Inserting messages_patient_template for the last inserted patient
            INSERT INTO openmrs.messages_patient_template (actor_id, actor_type, service_query,
                                                                    service_query_type,
                                                                    patient_id, template_id, uuid, creator,
                                                                    changed_by, date_changed, date_created, date_voided,
                                                                    void_reason, voided, voided_by,
                                                                    calendar_service_query)
            VALUES (@lastPersonID, NULL, NULL, NULL,
                    @lastPersonID, 1, UUID(), 1,
                    NULL, NULL, '2023-11-17 13:19:55', NULL,
                    NULL, 0, NULL, NULL),
                   (@lastPersonID, NULL, NULL, NULL,
                    @lastPersonID, 2, UUID(), 1,
                    NULL, NULL, '2023-11-17 13:19:55', NULL,
                    NULL, 0, NULL, NULL),
                   (@lastPersonID, NULL, NULL, NULL,
                    @lastPersonID, 3, UUID(), 1,
                    NULL, NULL, '2023-11-17 13:19:55', NULL,
                    NULL, 0, NULL, NULL);

-- Fetch the last inserted messages_template_field_value ID
            SET @lastMessageTemplateID :=
                    (SELECT MAX(messages_patient_template_id) FROM openmrs.messages_patient_template);

-- Inserting messages_template_field_value for the last inserted patient
            INSERT INTO openmrs.messages_template_field_value (value, template_field_id, patient_template_id,
                                                                        uuid,
                                                                        creator, changed_by, date_changed, date_created,
                                                                        date_voided, void_reason, voided, voided_by)
            VALUES (DATE(NOW()), 2, @lastMessageTemplateID, UUID(),
                    1, NULL, NULL, '2023-11-17 13:19:55',
                    NULL, NULL, 0, NULL),
                   ('Call', 1, @lastMessageTemplateID, UUID(),
                    1, NULL, NULL, '2023-11-17 13:19:55',
                    NULL, NULL, 0, NULL),
                   ('AFTER_TIMES|1', 3, @lastMessageTemplateID, UUID(),
                    1, NULL, NULL, '2023-11-17 13:19:55',
                    NULL, NULL, 0, NULL);


            SET counter = counter + 1;
        END WHILE;
END;


