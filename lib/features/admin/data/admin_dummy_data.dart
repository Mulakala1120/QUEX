/// Dummy admin data for UI screens (replaced by API later).
class AdminDummyData {
  static const appointments = [
    AdminAppointment('10:30 AM', 'Ravi Kumar', 'Haircut', 'Confirmed'),
    AdminAppointment('11:00 AM', 'Ananya Reddy', 'Consultation', 'Confirmed'),
    AdminAppointment('11:45 AM', 'Vikram Singh', 'Beard Trim', 'Pending'),
    AdminAppointment('12:30 PM', 'Priya Nair', 'Facial', 'Confirmed'),
  ];

  static const customers = [
    AdminCustomer('Ravi Kumar', '+91 98765 43210', 5, '19 May'),
    AdminCustomer('Ananya Reddy', '+91 91234 56789', 3, '12 Jun'),
    AdminCustomer('Vikram Singh', '+91 99887 76655', 8, '3 Jun'),
    AdminCustomer('Priya Nair', '+91 90001 23456', 2, '20 Jun'),
  ];

  static const services = [
    AdminService('Haircut', '30 min', '₹499', true),
    AdminService('Beard Trim', '15 min', '₹199', true),
    AdminService('Hair Spa', '45 min', '₹899', true),
    AdminService('Consultation', '20 min', '₹600', true),
    AdminService('Facial', '40 min', '₹750', false),
  ];

  static const staff = [
    AdminStaffMember('John Doe', 'Senior Stylist', 'Haircut, Styling', 'Active'),
    AdminStaffMember('Sneha Rao', 'Stylist', 'Haircut, Beard', 'Active'),
    AdminStaffMember('Dr. Priya Sharma', 'Physician', 'Consultation', 'On break'),
    AdminStaffMember('Kiran Patel', 'Receptionist', 'Queue ops', 'Active'),
  ];

  static const notifications = [
    AdminNotification('Queue', '3 customers waiting — est. wait 15 min', '2m ago'),
    AdminNotification('System', 'Daily analytics report is ready', '1h ago'),
    AdminNotification('Promo', 'Weekend offer draft saved', '3h ago'),
    AdminNotification('Queue', 'Walk-in added: Vikram Singh', '5h ago'),
  ];
}

class AdminAppointment {
  const AdminAppointment(this.time, this.name, this.service, this.status);
  final String time;
  final String name;
  final String service;
  final String status;
}

class AdminCustomer {
  const AdminCustomer(this.name, this.phone, this.visits, this.lastVisit);
  final String name;
  final String phone;
  final int visits;
  final String lastVisit;
}

class AdminService {
  const AdminService(this.name, this.duration, this.price, this.active);
  final String name;
  final String duration;
  final String price;
  final bool active;
}

class AdminStaffMember {
  const AdminStaffMember(this.name, this.role, this.services, this.status);
  final String name;
  final String role;
  final String services;
  final String status;
}

class AdminNotification {
  const AdminNotification(this.category, this.message, this.time);
  final String category;
  final String message;
  final String time;
}
