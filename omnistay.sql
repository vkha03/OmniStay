-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Máy chủ: 127.0.0.1
-- Thời gian đã tạo: Th4 01, 2026 lúc 05:48 AM
-- Phiên bản máy phục vụ: 10.4.32-MariaDB
-- Phiên bản PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Cơ sở dữ liệu: `omnistay`
--

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `bookings`
--

CREATE TABLE `bookings` (
  `id` int(11) NOT NULL,
  `booking_code` varchar(20) NOT NULL,
  `guest_id` int(11) NOT NULL,
  `check_in_date` date NOT NULL,
  `check_out_date` date NOT NULL,
  `total_amount` decimal(15,0) DEFAULT 0,
  `notes` text DEFAULT NULL,
  `status` varchar(50) DEFAULT 'PENDING' COMMENT 'PENDING, CONFIRMED, CHECKED_IN, COMPLETED, CANCELLED',
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `bookings`
--

INSERT INTO `bookings` (`id`, `booking_code`, `guest_id`, `check_in_date`, `check_out_date`, `total_amount`, `notes`, `status`, `created_at`) VALUES
(1, 'BKG2603001', 1, '2026-03-28', '2026-03-30', 7250000, 'Kỷ niệm ngày cưới, cần chuẩn bị hoa tươi', 'CHECKED_IN', '2026-03-25 10:00:00'),
(2, 'BKG2603002', 2, '2026-04-05', '2026-04-07', 3200000, 'Xin phòng tầng cao', 'CONFIRMED', '2026-03-29 08:30:00'),
(3, 'BKG2603003', 4, '2026-03-20', '2026-03-22', 2000000, 'Xuất hóa đơn công ty', 'COMPLETED', '2026-03-15 14:20:00');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `booking_rooms`
--

CREATE TABLE `booking_rooms` (
  `booking_id` int(11) NOT NULL,
  `room_id` int(11) NOT NULL,
  `historical_price` decimal(12,0) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `booking_rooms`
--

INSERT INTO `booking_rooms` (`booking_id`, `room_id`, `historical_price`) VALUES
(1, 11, 3200000),
(2, 6, 1600000),
(3, 1, 950000);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `booking_services`
--

CREATE TABLE `booking_services` (
  `id` int(11) NOT NULL,
  `booking_id` int(11) NOT NULL,
  `service_id` int(11) NOT NULL,
  `quantity` int(11) NOT NULL DEFAULT 1,
  `historical_price` decimal(12,0) NOT NULL,
  `used_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `booking_services`
--

INSERT INTO `booking_services` (`id`, `booking_id`, `service_id`, `quantity`, `historical_price`, `used_at`) VALUES
(1, 1, 2, 1, 850000, '2026-03-28 16:00:00'),
(2, 3, 6, 1, 100000, '2026-03-21 09:00:00');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `contacts`
--

CREATE TABLE `contacts` (
  `id` int(11) NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `subject` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `status` varchar(50) DEFAULT 'UNREAD' COMMENT 'UNREAD, RESOLVED',
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `contacts`
--

INSERT INTO `contacts` (`id`, `full_name`, `email`, `subject`, `message`, `status`, `created_at`) VALUES
(1, 'Hoàng Tú', 'tu.hoang@gmail.com', 'Hỏi về tiệc cưới', 'Khách sạn có nhận tổ chức tiệc cưới quy mô 100 khách không?', 'UNREAD', '2026-03-29 23:42:07'),
(2, 'Lý Mạc Sầu', 'lymacsau@gmail.com', 'Thất lạc đồ', 'Tôi để quên áo khoác ở phòng 101 ngày 22/3, xin kiểm tra giúp.', 'RESOLVED', '2026-03-29 23:42:07');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `guests`
--

CREATE TABLE `guests` (
  `id` int(11) NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `phone_number` varchar(20) NOT NULL,
  `email` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `guests`
--

INSERT INTO `guests` (`id`, `full_name`, `phone_number`, `email`) VALUES
(1, 'Trần Minh Khoa', '0901234567', 'khoa.tran@example.com'),
(2, 'Nguyễn Thị Lan', '0987654321', 'lan.nguyen@example.com'),
(3, 'Phạm Hồng Anh', '0912345678', 'honganh.pham@example.com'),
(4, 'Lê Văn Đạt', '0933445566', 'dat.le@example.com');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `rooms`
--

CREATE TABLE `rooms` (
  `id` int(11) NOT NULL,
  `room_number` varchar(20) NOT NULL,
  `room_type_id` int(11) NOT NULL,
  `status` varchar(50) DEFAULT 'AVAILABLE' COMMENT 'AVAILABLE, OCCUPIED, CLEANING, MAINTENANCE'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `rooms`
--

INSERT INTO `rooms` (`id`, `room_number`, `room_type_id`, `status`) VALUES
(1, '101', 1, 'AVAILABLE'),
(2, '102', 1, 'AVAILABLE'),
(3, '103', 1, 'OCCUPIED'),
(4, '104', 1, 'CLEANING'),
(5, '105', 1, 'AVAILABLE'),
(6, '201', 2, 'AVAILABLE'),
(7, '202', 2, 'OCCUPIED'),
(8, '203', 2, 'AVAILABLE'),
(9, '204', 2, 'MAINTENANCE'),
(10, '301', 3, 'AVAILABLE'),
(11, '302', 3, 'OCCUPIED');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `room_types`
--

CREATE TABLE `room_types` (
  `id` int(11) NOT NULL,
  `type_name` varchar(50) NOT NULL,
  `base_price` decimal(12,0) NOT NULL,
  `max_occupancy` int(11) NOT NULL,
  `description` text DEFAULT NULL,
  `image_url` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `room_types`
--

INSERT INTO `room_types` (`id`, `type_name`, `base_price`, `max_occupancy`, `description`, `image_url`) VALUES
(1, 'Ninh Kieu Standard', 950000, 2, 'Sàn gỗ sồi tự nhiên, thiết kế tối giản, view nhìn ra trung tâm thành phố nhộn nhịp.', 'https://images.unsplash.com/photo-1590490360182-c33d57733427?w=600&q=80'),
(2, 'Hau River Deluxe', 1600000, 2, 'Ban công rộng đón gió sông Hậu, bồn tắm sứ thủ công và nệm tiêu chuẩn 5 sao.', 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=600&q=80'),
(3, 'Mekong Heritage Suite', 3200000, 3, 'Phòng khách hoàng gia, nội thất khảm trai tinh xảo. Miễn phí trà chiều và đưa đón sân bay.', 'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=600&q=80');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `services`
--

CREATE TABLE `services` (
  `id` int(11) NOT NULL,
  `service_name` varchar(100) NOT NULL,
  `price` decimal(12,0) NOT NULL,
  `unit` varchar(50) NOT NULL COMMENT 'Bottle, Hour, Person'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `services`
--

INSERT INTO `services` (`id`, `service_name`, `price`, `unit`) VALUES
(1, 'Tour Chợ Nổi Cái Răng VIP', 500000, 'Người'),
(2, 'Sen Spa & Massage 90 phút', 850000, 'Lượt'),
(3, 'Xe Limousine đưa đón Sân bay', 350000, 'Chuyến'),
(4, 'Trà chiều Jade Lounge', 450000, 'Set 2 người'),
(5, 'Giường phụ (Extra Bed)', 400000, 'Đêm'),
(6, 'Giặt ủi tiêu chuẩn', 100000, 'Bộ');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `staff`
--

CREATE TABLE `staff` (
  `id` int(11) NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` varchar(20) NOT NULL DEFAULT 'RECEPTIONIST' COMMENT 'ADMIN or RECEPTIONIST',
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `staff`
--

INSERT INTO `staff` (`id`, `full_name`, `email`, `password`, `role`, `created_at`) VALUES
(1, 'Quản trị viên', 'admin@omnistay.vn', '123456', 'ADMIN', '2026-03-29 23:42:07'),
(2, 'Nguyễn Thị Lễ Tân', 'reception1@omnistay.vn', '123456', 'RECEPTIONIST', '2026-03-29 23:42:07'),
(3, 'Trần Văn Hỗ Trợ', 'reception2@omnistay.vn', '123456', 'RECEPTIONIST', '2026-03-29 23:42:07');

--
-- Chỉ mục cho các bảng đã đổ
--

--
-- Chỉ mục cho bảng `bookings`
--
ALTER TABLE `bookings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `booking_code` (`booking_code`),
  ADD KEY `guest_id` (`guest_id`);

--
-- Chỉ mục cho bảng `booking_rooms`
--
ALTER TABLE `booking_rooms`
  ADD PRIMARY KEY (`booking_id`,`room_id`),
  ADD KEY `room_id` (`room_id`);

--
-- Chỉ mục cho bảng `booking_services`
--
ALTER TABLE `booking_services`
  ADD PRIMARY KEY (`id`),
  ADD KEY `booking_id` (`booking_id`),
  ADD KEY `service_id` (`service_id`);

--
-- Chỉ mục cho bảng `contacts`
--
ALTER TABLE `contacts`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `guests`
--
ALTER TABLE `guests`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `rooms`
--
ALTER TABLE `rooms`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `room_number` (`room_number`),
  ADD KEY `room_type_id` (`room_type_id`);

--
-- Chỉ mục cho bảng `room_types`
--
ALTER TABLE `room_types`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `services`
--
ALTER TABLE `services`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `staff`
--
ALTER TABLE `staff`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT cho các bảng đã đổ
--

--
-- AUTO_INCREMENT cho bảng `bookings`
--
ALTER TABLE `bookings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT cho bảng `booking_services`
--
ALTER TABLE `booking_services`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT cho bảng `contacts`
--
ALTER TABLE `contacts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT cho bảng `guests`
--
ALTER TABLE `guests`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT cho bảng `rooms`
--
ALTER TABLE `rooms`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT cho bảng `room_types`
--
ALTER TABLE `room_types`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT cho bảng `services`
--
ALTER TABLE `services`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT cho bảng `staff`
--
ALTER TABLE `staff`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Các ràng buộc cho các bảng đã đổ
--

--
-- Các ràng buộc cho bảng `bookings`
--
ALTER TABLE `bookings`
  ADD CONSTRAINT `bookings_ibfk_1` FOREIGN KEY (`guest_id`) REFERENCES `guests` (`id`);

--
-- Các ràng buộc cho bảng `booking_rooms`
--
ALTER TABLE `booking_rooms`
  ADD CONSTRAINT `booking_rooms_ibfk_1` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `booking_rooms_ibfk_2` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`id`);

--
-- Các ràng buộc cho bảng `booking_services`
--
ALTER TABLE `booking_services`
  ADD CONSTRAINT `booking_services_ibfk_1` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `booking_services_ibfk_2` FOREIGN KEY (`service_id`) REFERENCES `services` (`id`);

--
-- Các ràng buộc cho bảng `rooms`
--
ALTER TABLE `rooms`
  ADD CONSTRAINT `rooms_ibfk_1` FOREIGN KEY (`room_type_id`) REFERENCES `room_types` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
