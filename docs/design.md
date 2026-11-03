# System Design: ShiftDesk

## System Architecture

### User
Represents both managers and employees. Stores authentication details, role, and association to a business.  

### Business
Represents the organization for multi-tenant isolation, owning users, shifts, and requests.  

### Shift
Represents a scheduled work slot. Stores start and end timestamps.
