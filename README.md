This is a project to consume HQMF XML Files and produce json

Environment
===========

This project currently uses Ruby 1.9.2 and is built using [Bundler](http://gembundler.com/). To get all of the dependencies for the project, first install bundler:

    gem install bundler

Then run bundler to grab all of the necessary gems:

    bundle install

Project Practices
=================

Please try to follow our [Coding Style Guides](http://github.com/eedrummer/styleguide). Additionally, we will be using git in a pattern similar to [Vincent Driessen's workflow](http://nvie.com/posts/a-successful-git-branching-model/). While feature branches are encouraged, they are not required to work on the project.

License
=======

Copyright 2011 The MITRE Corporation

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

Data Mappings
=======

PATIENT API FUNCTIONS
  allProblems => conditions, socialHistories
  encounters => encounters
  allProcedures => procedures, immunizations, medications
  procedureResults => results, vitalSigns, procedures
  allergies => allergies
  allMedications => medications, immunizations
  laboratoryTests => results, vitalSigns
  careGoals => careGoals
  procedures => procedures
  allDevices => conditions, procedures, careGoals, medicalEquipment

CATEGORIES
  characteristic
  encounters
  procedures
  conditions
  diagnostic_studies
  medications
  physical_exams
  laboratory_tests
  care_goals
  communications
  devices
  substances
  interventions
  symptoms
  functional_statuses
  risk_category_assessments
  provider_care_experiences
  patient_care_experiences
  preferences
  system_characteristics
  provider_characteristics
  transfers

SUB CATEGORIES BY CATEGORY
characteristic
  birthdate
  age
  marital_status
  languages
  clinical_trial_participant
  gender
  ethnicity
  expired
  payer
  race
procedures
  result
  adverse_event
  intolerance
conditions
  family_history
  risk_of
diagnostic_studies
  result
  adverse_event
  intolerance
medications
  adverse_effects
  allergy
  intolerance
laboratory_tests
  adverse_event
  intolerance
communications
  from_patient_to_provider
  from_provider_to_patient
  from_provider_to_provider
devices
  adverse_event
  allergy
  intolerance
substances
  adverse_event
  intolerance
  allergy
interventions
  adverse_event
  intolerance
  result
functional_statuses
  result
preferences
  provider
  patient
system_characteristics
provider_characteristics
transfers
  from
  to


STATUSES
  active, performed, ordered, recommended, resolved, inactive, dispensed, administered, applied, assessed, final report


STATUSES BY CATEGORY

  encounters
    active
    performed
    ordered
    recommended
  procedures
    performed
    ordered
    recommended
  conditions
    active
    resolved
    inactive
  diagnostic_studies
    performed
    ordered
    final report
  medications
    dispensed
    ordered
    active
    administered
  physical_exams
    ordered
    performed
    recommended
  laboratory_tests
    performed
    ordered
    recommended
  devices
    applied
    ordered
    recommended
  substances
    administered
    ordered
    recommended
  interventions
    ordered
    performed
    recommended
  symptoms
    active
    assessed
    inactive
    resolved
  functional_statuses
    performed
    ordered
    recommended


CHARACTERISTIC
-------
2.16.840.1.113883.3.560.1.1001
     patient_characteristic
     allProblems
2.16.840.1.113883.3.560.1.25
     patient_characteristic_birthdate
     birthtime
2.16.840.1.113883.3.560.1.400
     patient_characteristic_birthdate
     birthtime
2.16.840.1.113883.3.560.1.401
     patient_characteristic_clinical_trial_participant
     clinical_trial_participant
2.16.840.1.113883.3.560.1.402
     patient_characteristic_gender
     gender
2.16.840.1.113883.3.560.1.403
     patient_characteristic_ethnicity
     ethnicity
2.16.840.1.113883.3.560.1.404
     patient_characteristic_expired
     expired
2.16.840.1.113883.3.560.1.405
     patient_characteristic_payer
     payer
2.16.840.1.113883.3.560.1.406
     patient_characteristic_race
     race

ENCOUNTERS
-------
2.16.840.1.113883.3.560.1.4
     encounter
     encounters
2.16.840.1.113883.3.560.1.81
     encounter_active
     encounters
2.16.840.1.113883.3.560.1.79
     encounter_performed
     encounters
2.16.840.1.113883.3.560.1.82
     encounter_performed
     encounters
2.16.840.1.113883.3.560.1.83
     encounter_ordered
     encounters
2.16.840.1.113883.3.560.1.84
     encounter_recommended
     encounters
2.16.840.1.113883.3.560.1.179
     encounter_performed
     encounters
     negation=true
2.16.840.1.113883.3.560.1.182
     encounter_performed
     encounters
     NEGATION
2.16.840.1.113883.3.560.1.181
     encounter_active
     encounters
     NEGATION
2.16.840.1.113883.3.560.1.183
     encounter_ordered
     encounters
     NEGATION
2.16.840.1.113883.3.560.1.184
     encounter_recommended
     encounters
     NEGATION
2.16.840.1.113883.3.560.1.104
     encounter
     encounters
     NEGATION

PROCEDURES
-------
2.16.840.1.113883.3.560.1.6
     procedure_performed
     allProcedures
2.16.840.1.113883.3.560.1.62
     procedure_ordered
     allProcedures
2.16.840.1.113883.3.560.1.63
     procedure_result
     procedureResults
2.16.840.1.113883.3.560.1.60
     procedure_adverse_event
     allergies
2.16.840.1.113883.3.560.1.61
     procedure_intolerance
     allergies
2.16.840.1.113883.3.560.1.92
     procedure_recommended
     allProcedures
2.16.840.1.113883.3.560.1.162
     procedure_ordered
     allProcedures
     NEGATION
2.16.840.1.113883.3.560.1.163
     procedure_result
     procedureResults
     NEGATION
2.16.840.1.113883.3.560.1.160
     procedure_adverse_event
     allergies
     NEGATION
2.16.840.1.113883.3.560.1.161
     procedure_intolerance
     allergies
     NEGATION
2.16.840.1.113883.3.560.1.106
     procedure_performed
     allProcedures
     NEGATION
2.16.840.1.113883.3.560.1.192
     procedure_recommended
     allProcedures
     NEGATION

CONDITIONS
-------
2.16.840.1.113883.3.560.1.2
     diagnosis_active
     allProblems
2.16.840.1.113883.3.560.1.24
     diagnosis_resolved
     allProblems
2.16.840.1.113883.3.560.1.32
     diagnosis_family_history
     N/A
2.16.840.1.113883.3.560.1.23
     diagnosis_inactive
     allProblems
2.16.840.1.113883.3.560.1.33
     diagnosis_risk_of
     N/A
2.16.840.1.113883.3.560.1.124
     diagnosis_resolved
     allProblems
     NEGATION
2.16.840.1.113883.3.560.1.132
     diagnosis_family_history
     N/A
     NEGATION
2.16.840.1.113883.3.560.1.123
     diagnosis_inactive
     allProblems
     NEGATION
2.16.840.1.113883.3.560.1.102
     diagnosis_active
     allProblems
     NEGATION
2.16.840.1.113883.3.560.1.133
     diagnosis_risk_of
     N/A
     NEGATION

DIAGNOSTIC STUDIES
-------
2.16.840.1.113883.3.560.1.3
     diagnostic_study_performed
     allProcedures
2.16.840.1.113883.3.560.1.11
     diagnostic_study_result
     procedureResults
2.16.840.1.113883.3.560.1.38
     diagnostic_study_adverse_event
     allergies
2.16.840.1.113883.3.560.1.39
     diagnostic_study_intolerance
     allergies
2.16.840.1.113883.3.560.1.40
     diagnostic_study_ordered
     allProcedures
2.16.840.1.113883.3.560.1.103
     diagnostic_study_performed
     allProcedures
     NEGATION
2.16.840.1.113883.3.560.1.138
     diagnostic_study_adverse_event
     allergies
     NEGATION
2.16.840.1.113883.3.560.1.139
     diagnostic_study_intolerance
     allergies
     NEGATION
2.16.840.1.113883.3.560.1.140
     diagnostic_study_ordered
     allProcedures
     NEGATION
2.16.840.1.113883.3.560.1.111
     diagnostic_study_result
     procedureResults
     NEGATION

MEDICATIONS
-------
2.16.840.1.113883.3.560.1.8
     medication_dispensed
     allMedications
2.16.840.1.113883.3.560.1.17
     medication_ordered
     allMedications
2.16.840.1.113883.3.560.1.13
     medication_active
     allMedications
2.16.840.1.113883.3.560.1.14
     medication_administered
     allMedications
2.16.840.1.113883.3.560.1.7
     medication_adverse_effects
     allergies
2.16.840.1.113883.3.560.1.1
     medication_allergy
     allergies
2.16.840.1.113883.3.560.1.15
     medication_intolerance
     allergies
2.16.840.1.113883.3.560.1.77
     medication
     allMedications
     NEGATION
2.16.840.1.113883.3.560.1.78
     medication_ordered
     allMedications
     NEGATION
2.16.840.1.113883.3.560.1.108
     medication_dispensed
     allMedications
     NEGATION
2.16.840.1.113883.3.560.1.113
     medication_active
     allMedications
     NEGATION
2.16.840.1.113883.3.560.1.107
     medication_adverse_effects
     allergies
     NEGATION
2.16.840.1.113883.3.560.1.101
     medication_allergy
     allergies
     NEGATION
2.16.840.1.113883.3.560.1.115
     medication_intolerance
     allergies
     NEGATION
2.16.840.1.113883.3.560.1.114
     medication_administered
     allMedications
     NEGATION

PHYSICAL EXAMS
-------
2.16.840.1.113883.3.560.1.19
     physical_exam
     procedureResults
2.16.840.1.113883.3.560.1.18
     physical_exam
     procedureResults
2.16.840.1.113883.3.560.1.56
     physical_exam_ordered
     procedureResults
2.16.840.1.113883.3.560.1.57
     physical_exam_performed
     procedureResults
2.16.840.1.113883.3.560.1.91
     physical_exam_recommended
     procedureResults
2.16.840.1.113883.3.560.1.156
     physical_exam_ordered
     procedureResults
     NEGATION
2.16.840.1.113883.3.560.1.157
     physical_exam_performed
     procedureResults
     NEGATION
2.16.840.1.113883.3.560.1.191
     physical_exam_recommended
     procedureResults
     NEGATION
2.16.840.1.113883.3.560.1.118
     physical_exam
     procedureResults
     NEGATION

LABORATORY TESTS
--------
2.16.840.1.113883.3.560.1.12
     laboratory_test
     laboratoryTests
2.16.840.1.113883.3.560.1.5
     laboratory_test_performed
     laboratoryTests
2.16.840.1.113883.3.560.1.48
     laboratory_test_adverse_event
     allergies
2.16.840.1.113883.3.560.1.49
     laboratory_test_intolerance
     allergies
2.16.840.1.113883.3.560.1.50
     laboratory_test_ordered
     laboratoryTests
2.16.840.1.113883.3.560.1.90
     laboratory_test_recommended
     laboratoryTests
2.16.840.1.113883.3.560.1.112
     laboratory_test
     laboratoryTests
     NEGATION
2.16.840.1.113883.3.560.1.148
     laboratory_test_adverse_event
     allergies
     NEGATION
2.16.840.1.113883.3.560.1.149
     laboratory_test_intolerance
     allergies
     NEGATION
2.16.840.1.113883.3.560.1.150
     laboratory_test_ordered
     laboratoryTests
     NEGATION
2.16.840.1.113883.3.560.1.190
     laboratory_test_recommended
     laboratoryTests
     NEGATION
2.16.840.1.113883.3.560.1.105
     laboratory_test_performed
     laboratoryTests
     NEGATION

CARE GOALS
--------
2.16.840.1.113883.3.560.1.9
     care_goal
     careGoals
2.16.840.1.113883.3.560.1.109
     care_goal
     careGoals
     NEGATION

COMMUNICATIONS
--------
2.16.840.1.113883.3.560.1.30
     communication_from_patient_to_provider
     procedures
2.16.840.1.113883.3.560.1.31
     communication_from_provider_to_patient
     procedures
2.16.840.1.113883.3.560.1.29
     communication_from_provider_to_provider
     procedures
2.16.840.1.113883.3.560.1.130
     communication_from_patient_to_provider
     procedures
     NEGATION
2.16.840.1.113883.3.560.1.131
     communication_from_provider_to_patient
     procedures
     NEGATION
2.16.840.1.113883.3.560.1.129
     communication_from_provider_to_provider
     procedures
     NEGATION

DEVICES
-------
2.16.840.1.113883.3.560.1.10
     device_applied
     allDevices
2.16.840.1.113883.3.560.1.34
     device_adverse_event
     allergies
2.16.840.1.113883.3.560.1.35
     device_allergy
     allergies
2.16.840.1.113883.3.560.1.36
     device_intolerance
     allergies
2.16.840.1.113883.3.560.1.37
     device_ordered
     allDevices
2.16.840.1.113883.3.560.1.80
     device_recommended
     allDevices
2.16.840.1.113883.3.560.1.134
     device_adverse_event
     allergies
     NEGATION
2.16.840.1.113883.3.560.1.135
     device_allergy
     allergies
     NEGATION
2.16.840.1.113883.3.560.1.136
     device_intolerance
     allergies
     NEGATION
2.16.840.1.113883.3.560.1.137
     device_ordered
     allDevices
     NEGATION
2.16.840.1.113883.3.560.1.180
     device_recommended
     allDevices
     NEGATION
2.16.840.1.113883.3.560.1.110
     device_applied
     allDevices
     NEGATION

SUBSTANCES
-------
2.16.840.1.113883.3.560.1.64
     substance_administered
     allMedications
2.16.840.1.113883.3.560.1.68
     substance_ordered
     allMedications
2.16.840.1.113883.3.560.1.65
     substance_adverse_event
     allergies
2.16.840.1.113883.3.560.1.67
     substance_intolerance
     allergies
2.16.840.1.113883.3.560.1.66
     substance_allergy
     allergies
2.16.840.1.113883.3.560.1.93
     substance_recommended
     allMedications
2.16.840.1.113883.3.560.1.165
     substance_adverse_event
     allergies
     NEGATION
2.16.840.1.113883.3.560.1.167
     substance_intolerance
     allergies
     NEGATION
2.16.840.1.113883.3.560.1.164
     substance_administered
     allMedications
     NEGATION
2.16.840.1.113883.3.560.1.168
     substance_ordered
     allMedications
     NEGATION
2.16.840.1.113883.3.560.1.193
     substance_recommended
     allMedications
     NEGATION
2.16.840.1.113883.3.560.1.166
     substance_allergy
     allergies
     NEGATION

INTERVENTIONS
-------
2.16.840.1.113883.3.560.1.43
     intervention_adverse_event
     allergies
2.16.840.1.113883.3.560.1.44
     intervention_intolerance
     allergies
2.16.840.1.113883.3.560.1.45
     intervention_ordered
     procedures
2.16.840.1.113883.3.560.1.46
     intervention_performed
     procedures
2.16.840.1.113883.3.560.1.47
     intervention_result
     procedureResults
2.16.840.1.113883.3.560.1.89
     intervention_recommended
     procedures
2.16.840.1.113883.3.560.1.143
     intervention_adverse_event
     allergies
     NEGATION
2.16.840.1.113883.3.560.1.144
     intervention_intolerance
     allergies
     NEGATION
2.16.840.1.113883.3.560.1.145
     intervention_ordered
     procedures
     NEGATION
2.16.840.1.113883.3.560.1.146
     intervention_performed
     procedures
     NEGATION
2.16.840.1.113883.3.560.1.147
     intervention_result
     procedureResults
     NEGATION
2.16.840.1.113883.3.560.1.189
     intervention_recommended
     procedures
     NEGATION

SYMPTOMS
-------
2.16.840.1.113883.3.560.1.69
     symptom_active
     allProblems
2.16.840.1.113883.3.560.1.70
     symptom_assessed
     allProblems
2.16.840.1.113883.3.560.1.97
     symptom_inactive
     allProblems
2.16.840.1.113883.3.560.1.98
     symptom_resolved
     allProblems
2.16.840.1.113883.3.560.1.169
     symptom_active
     allProblems
     NEGATION
2.16.840.1.113883.3.560.1.170
     symptom_assessed
     allProblems
     NEGATION
2.16.840.1.113883.3.560.1.197
     symptom_inactive
     allProblems
     NEGATION
2.16.840.1.113883.3.560.1.198
     symptom_resolved
     allProblems
     NEGATION

FUNCTIONAL STATUSES
-------
2.16.840.1.113883.3.560.1.41
     functional_status
     procedureResults
2.16.840.1.113883.3.560.1.85
     functional_status_performed
     procedureResults
2.16.840.1.113883.3.560.1.86
     functional_status_ordered
     procedureResults
2.16.840.1.113883.3.560.1.87
     functional_status_recommended
     procedureResults
2.16.840.1.113883.3.560.1.88
     functional_status_result
     procedureResults
2.16.840.1.113883.3.560.1.185
     functional_status_performed
     procedureResults
     NEGATION
2.16.840.1.113883.3.560.1.186
     functional_status_ordered
     procedureResults
     NEGATION
2.16.840.1.113883.3.560.1.187
     functional_status_recommended
     procedureResults
     NEGATION
2.16.840.1.113883.3.560.1.188
     functional_status_result
     procedureResults
     NEGATION
2.16.840.1.113883.3.560.1.141
     functional_status
     procedureResults
     NEGATION

RISK CATEGORY/ASSESSMENTS
2.16.840.1.113883.3.560.1.21
     risk_category_assessment
     procedures
2.16.840.1.113883.3.560.1.121
     risk_category_assessment
     procedures
     NEGATION

PROVIDER_CARE_EXPERIENCES
-------
2.16.840.1.113883.3.560.1.28
     provider_care_experience
     N/A
2.16.840.1.113883.3.560.1.128
     provider_care_experience
     N/A
     NEGATION

PATIENT_CARE_EXPERIENCES
-------
2.16.840.1.113883.3.560.1.96
     patient_care_experience
     N/A
2.16.840.1.113883.3.560.1.196
     patient_care_experience
     N/A
     NEGATION

PREFERENCES
-------
2.16.840.1.113883.3.560.1.59
     preference_provider
     N/A
2.16.840.1.113883.3.560.1.58
     preference_patient
     N/A

SYSTEM CHARACTERISTICS
-------
2.16.840.1.113883.3.560.1.94
     system_characteristic
     N/A
2.16.840.1.113883.3.560.1.194
     system_characteristic
     N/A
     NEGATION

PROVIDER CHARACTERISTICS
-------
2.16.840.1.113883.3.560.1.95
     provider_characteristic
     N/A
2.16.840.1.113883.3.560.1.195
     provider_characteristic
     N/A
     NEGATION

TRANSFERS
-------
2.16.840.1.113883.3.560.1.71
     transfer_from
     N/A
2.16.840.1.113883.3.560.1.72
     transfer_to
     N/A
2.16.840.1.113883.3.560.1.171
     transfer_from
     N/A
     NEGATION
2.16.840.1.113883.3.560.1.172
     transfer_to
     N/A
     NEGATION
     