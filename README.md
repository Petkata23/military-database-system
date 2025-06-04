# 🪖 Military Database System

A fully-featured SQL military database system with units, equipment, events, and facility management.  
This project was originally developed as a school assignment and expanded with additional views, functions, and triggers to demonstrate advanced SQL usage.

---

## 📁 Project Structure

This project contains a complete SQL schema with:

- Military Units (Infantry, Armored Division, etc.)
- Facilities (Base Camps, Training Centers, etc.)
- Military Events (Exercises, Missions, Parades)
- Equipment (Firearms, Tanks, Optical Gear)
- Equipment participation in Events

---

## 🔍 Key Features

- ✅ Relational structure with `FOREIGN KEY` constraints
- ✅ Input validation using `CHECK` and `UNIQUE`
- ✅ Advanced queries with `JOIN`, `UNION`, `GROUP_CONCAT`, and subqueries
- ✅ `VIEWS` for analytics and reporting
- ✅ A `FUNCTION` to count events by equipment type
- ✅ `TRIGGER` for logging new unit creation
- ✅ Sample `TRANSACTION` with rollback-safe updates

---

## 🧪 Sample Queries Included

- List of all equipment and events, combined
- Units and their respective equipment
- Units with above-average facility capacity
- Analytics: equipment counts, average capacity, usage in events

---

## 📊 Views and Logic

- `unit_equipment_count`: number of equipment items per unit  
- `avg_facility_capacity`: average capacity by facility type  
- `event_equipment_count`: how often each equipment type is used in events  
- `event_equipment_list`: which items are used in which events  

---

## ⚙️ Function Example

```sql
SELECT count_events_by_equipment_type('Firearm') AS event_count;
```

Returns the number of events involving firearm equipment.

---

## 🔁 Trigger Example

Whenever a new unit is inserted into `military_units`, a log entry is automatically created in the `logs` table.

---

## 🏁 Getting Started

1. Import the `military.sql` file into your MySQL/MariaDB database.
2. Explore the schema and run included queries.
3. Extend or modify as needed for learning or demonstration purposes.

---

## 📚 Educational Use

> This project was created as part of a school assignment and enhanced for learning and practice.  
> Feel free to use it for personal study, demonstrations, or teaching purposes.

---

## 🧑‍💻 Author

**Petkata**  
