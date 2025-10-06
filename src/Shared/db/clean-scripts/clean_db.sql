SET session_replication_role = replica;

TRUNCATE TABLE
    "Attendance",
    "Training",
    "Membership",
    "TrainingRoom",
    "MembershipType",
    "Trainer",
    "User"
RESTART IDENTITY CASCADE;

SET session_replication_role = DEFAULT;

