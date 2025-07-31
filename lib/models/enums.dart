enum UserRole { client, provider }

enum ServiceCategory {
  cleaning,
  repair,
  delivery,
  cooking,
  health,
  beauty,
  education,
  transport,
  gardening,
  technology
}

enum PriceType {
  hourly,
  fixed,
  perUnit,
  perKm,
  perItem
}

enum BookingStatus {
  pending,
  confirmed,
  inProgress,
  completed,
  cancelled,
  disputed
}

enum PaymentMethod {
  wave,
  orangeMoney,
  creditCard,
  cash
}

enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  refunded
}

enum MessageType {
  text,
  image,
  document,
  audio,
  location,
  booking,
  payment
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed
}

enum AttachmentType {
  image,
  document,
  audio,
  video
}

