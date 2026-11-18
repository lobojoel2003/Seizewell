# FHIR export

**More → Export data → FHIR R4 (JSON)** produces one
[FHIR R4](https://hl7.org/fhir/R4/) `Bundle` of type `collection`. Every entry
has a `urn:uuid:` `fullUrl`; references between resources use those URLs.

| Resource | One per | Coding |
| --- | --- | --- |
| `Patient` | export | `name.text` and `birthDate` if entered in the profile |
| `Observation` | seizure | `code`: SNOMED CT **91175000** *Seizure (finding)* |
| `Observation` | night of sleep | `code`: LOINC **93832-4** *Sleep duration*, `valueQuantity` in `h` (UCUM) |
| `MedicationStatement` | medication | `medicationCodeableConcept.text`, `status` `active`/`stopped`, start/stop in `effectivePeriod`, every change in `note` |

## Seizure observations

| Element | Content |
| --- | --- |
| `status` | `final` |
| `effectivePeriod.start` / `.end` | Start and end with UTC offset. `end` is omitted when the duration was not witnessed. |
| `issued` | Last edited |
| `performer[0].display` | `Patient` or `Caregiver` |
| `valueCodeableConcept` | Seizure type, code system `…/CodeSystem/seizure-type` (below) |
| `component` | See below |
| `note[0].text` | Free-text notes |

Components use the code system
`https://github.com/lobojoel2003/Seizewell/fhir/CodeSystem/observation-component`:

| Code | Value |
| --- | --- |
| `duration` | `valueQuantity`, seconds (`s`, UCUM) — only when witnessed |
| `duration-known` | `valueBoolean` |
| `trigger` | `valueString`, one component per suspected trigger |
| `aura` | `valueBoolean` — warning or aura beforehand |
| `during-sleep` | `valueBoolean` |
| `injury` | `valueBoolean` |
| `emergency-care` | `valueBoolean` — ambulance, ER or hospital |
| `rescue-medication-time` | `valueDateTime` |
| `rescue-medication` | `valueString` |

Sleep observations may carry a `sleep-quality` component (`valueInteger`,
1 = very poor … 5 = great).

## Seizure-type code system

`https://github.com/lobojoel2003/Seizewell/fhir/CodeSystem/seizure-type`
follows the ILAE 2017 operational classification, simplified for patients
and caregivers:

| Code | Display |
| --- | --- |
| `focal-aware` | Focal aware |
| `focal-impaired` | Focal impaired awareness |
| `focal-to-bilateral` | Focal to bilateral tonic-clonic |
| `tonic-clonic` | Generalized tonic-clonic |
| `absence` | Absence |
| `myoclonic` | Myoclonic |
| `atonic` | Atonic (drop) |
| `tonic` | Tonic |
| `clonic` | Clonic |
| `spasms` | Epileptic spasms |
| `unknown` | Not sure / other |

The same codes appear in the `type_code` column of the CSV export.
