-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Máy chủ: 127.0.0.1
-- Thời gian đã tạo: Th5 10, 2026 lúc 02:31 PM
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
  `created_at` datetime DEFAULT current_timestamp(),
  `customer_full_name` varchar(100) DEFAULT NULL,
  `customer_email` varchar(100) DEFAULT NULL,
  `customer_phone` varchar(20) DEFAULT NULL,
  `customer_id_card` varchar(20) DEFAULT NULL,
  `num_adults` int(11) DEFAULT 1,
  `num_children` int(11) DEFAULT 0,
  `payment_method` varchar(50) DEFAULT 'CASH',
  `payment_status` varchar(50) DEFAULT 'UNPAID',
  `paid_amount` decimal(15,0) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `bookings`
--

INSERT INTO `bookings` (`id`, `booking_code`, `guest_id`, `check_in_date`, `check_out_date`, `total_amount`, `notes`, `status`, `created_at`, `customer_full_name`, `customer_email`, `customer_phone`, `customer_id_card`, `num_adults`, `num_children`, `payment_method`, `payment_status`, `paid_amount`) VALUES
(1, 'BKG2602001', 43, '2026-02-22', '2026-02-25', 4500000, 'Ghi chú tự động', 'COMPLETED', '2026-02-11 17:21:00', 'Hồ Quang Đạt', 'hồquangđạt13@gmail.com', '0944446182', '082757773474', 2, 0, 'CASH', 'PAID', 4500000),
(2, 'BKG2605002', 30, '2026-05-18', '2026-05-23', 4750000, 'Ghi chú tự động', 'CONFIRMED', '2026-05-06 14:31:00', 'Đặng Hữu Tuấn', 'đặnghữutuấn11@gmail.com', '0909736572', '089148190503', 2, 0, 'CREDIT_CARD', 'PAID', 4750000),
(3, 'BKG2602003', 50, '2026-02-28', '2026-03-04', 14500000, 'Ghi chú tự động', 'COMPLETED', '2026-02-15 19:33:00', 'Bùi Hữu Hân', 'bùihữuhân96@gmail.com', '0959345683', '088097709722', 2, 0, 'VNPAY', 'PAID', 14500000),
(4, 'BKG2606004', 40, '2026-06-10', '2026-06-14', 6400000, 'Ghi chú tự động', 'PENDING', '2026-06-01 15:57:00', 'Huỳnh Xuân Ngọc', 'huỳnhxuânngọc41@gmail.com', '0989913412', '075440889099', 2, 0, 'VNPAY', 'UNPAID', 0),
(5, 'BKG2604005', 16, '2026-04-12', '2026-04-17', 8800000, 'Ghi chú tự động', 'COMPLETED', '2026-04-08 12:28:00', 'Dương Đức Hân', 'dươngđứchân41@gmail.com', '0916240908', '070965067727', 2, 0, 'VNPAY', 'PAID', 8800000),
(6, 'BKG2605006', 5, '2026-05-18', '2026-05-22', 6400000, 'Ghi chú tự động', 'CONFIRMED', '2026-05-10 14:03:00', 'Võ Thị Linh', 'võthịlinh50@gmail.com', '0976125617', '085029083825', 2, 0, 'CREDIT_CARD', 'PAID', 6400000),
(7, 'BKG2602007', 38, '2026-02-06', '2026-02-11', 12200000, 'Ghi chú tự động', 'COMPLETED', '2026-02-05 13:19:00', 'Đặng Xuân Khang', 'đặngxuânkhang36@gmail.com', '0948024342', '077224421430', 2, 0, 'CREDIT_CARD', 'PAID', 12200000),
(8, 'BKG2605008', 42, '2026-05-21', '2026-05-23', 1900000, 'Ghi chú tự động', 'PENDING', '2026-05-18 08:16:00', 'Nguyễn Quang Linh', 'nguyễnquanglinh52@gmail.com', '0953481198', '081911347222', 2, 0, 'VNPAY', 'UNPAID', 0),
(9, 'BKG2605009', 49, '2026-05-09', '2026-05-12', 4850000, 'Ghi chú tự động', 'CHECKED_IN', '2026-04-26 21:26:00', 'Hồ Đức Kha', 'hồđứckha46@gmail.com', '0940785405', '083787629633', 2, 0, 'VNPAY', 'PAID', 4850000),
(10, 'BKG2603010', 16, '2026-03-24', '2026-03-25', 3800000, 'Ghi chú tự động', 'COMPLETED', '2026-03-20 10:30:00', 'Dương Đức Hân', 'dươngđứchân41@gmail.com', '0916240908', '070965067727', 2, 0, 'VNPAY', 'PAID', 3800000),
(11, 'BKG2602011', 20, '2026-02-28', '2026-03-05', 18550000, 'Ghi chú tự động', 'COMPLETED', '2026-02-23 17:43:00', 'Ngô Thu Hân', 'ngôthuhân16@gmail.com', '0997854904', '070422701550', 2, 0, 'CASH', 'PAID', 18550000),
(12, 'BKG2604012', 3, '2026-04-30', '2026-05-05', 7000000, 'Ghi chú tự động', 'COMPLETED', '2026-04-24 09:32:00', 'Lê Thái Hùng', 'lêtháihùng41@gmail.com', '0971691040', '083586710255', 2, 0, 'VNPAY', 'PAID', 7000000),
(13, 'BKG2606013', 35, '2026-06-04', '2026-06-08', 3800000, 'Ghi chú tự động', 'CONFIRMED', '2026-05-23 17:17:00', 'Trần Thị Ngọc', 'trầnthịngọc15@gmail.com', '0937135391', '078605163214', 2, 0, 'VNPAY', 'PAID', 3800000),
(14, 'BKG2604014', 29, '2026-04-04', '2026-04-08', 6600000, 'Ghi chú tự động', 'COMPLETED', '2026-03-24 14:21:00', 'Bùi Hoàng Linh', 'bùihoànglinh50@gmail.com', '0989889098', '079615082973', 2, 0, 'VNPAY', 'PAID', 6600000),
(15, 'BKG2606015', 1, '2026-06-13', '2026-06-15', 1900000, 'Ghi chú tự động', 'CONFIRMED', '2026-06-01 14:31:00', 'Vũ Hoàng Thảo', 'vũhoàngthảo22@gmail.com', '0931244663', '080222564311', 2, 0, 'CASH', 'PAID', 1900000),
(16, 'BKG2605016', 32, '2026-05-26', '2026-05-27', 3200000, 'Ghi chú tự động', 'CONFIRMED', '2026-05-22 14:44:00', 'Đặng Minh Hân', 'đặngminhhân48@gmail.com', '0972909480', '089988676070', 2, 0, 'VNPAY', 'PAID', 3200000),
(17, 'BKG2604017', 34, '2026-04-30', '2026-05-04', 6400000, 'Ghi chú tự động', 'CANCELLED', '2026-04-21 13:22:00', 'Phan Xuân Linh', 'phanxuânlinh91@gmail.com', '0992274302', '082253167242', 2, 0, 'VNPAY', 'REFUNDED', 0),
(18, 'BKG2603018', 8, '2026-03-22', '2026-03-25', 4350000, 'Ghi chú tự động', 'COMPLETED', '2026-03-13 20:44:00', 'Phạm Minh Hùng', 'phạmminhhùng64@gmail.com', '0991332642', '072561557300', 2, 0, 'VNPAY', 'PAID', 4350000),
(19, 'BKG2604019', 9, '2026-04-12', '2026-04-13', 6100000, 'Ghi chú tự động', 'CANCELLED', '2026-04-03 12:44:00', 'Dương Đức Mai', 'dươngđứcmai11@gmail.com', '0974252722', '081814930192', 2, 0, 'CREDIT_CARD', 'REFUNDED', 0),
(20, 'BKG2604020', 37, '2026-04-14', '2026-04-18', 6400000, 'Ghi chú tự động', 'COMPLETED', '2026-04-08 10:03:00', 'Hoàng Đức Khang', 'hoàngđứckhang84@gmail.com', '0949555330', '076668044514', 2, 0, 'CREDIT_CARD', 'PAID', 6400000),
(21, 'BKG2604021', 37, '2026-04-19', '2026-04-20', 4500000, 'Ghi chú tự động', 'CANCELLED', '2026-04-17 16:48:00', 'Hoàng Đức Khang', 'hoàngđứckhang84@gmail.com', '0949555330', '076668044514', 2, 0, 'VNPAY', 'REFUNDED', 0),
(22, 'BKG2605022', 34, '2026-05-09', '2026-05-13', 8300000, 'Ghi chú tự động', 'CHECKED_IN', '2026-05-01 12:55:00', 'Phan Xuân Linh', 'phanxuânlinh91@gmail.com', '0992274302', '082253167242', 2, 0, 'CASH', 'PAID', 8300000),
(23, 'BKG2604023', 11, '2026-04-03', '2026-04-05', 11650000, 'Ghi chú tự động', 'COMPLETED', '2026-03-31 08:26:00', 'Phạm Quang Hoa', 'phạmquanghoa74@gmail.com', '0985758349', '076910474439', 2, 0, 'CASH', 'PAID', 11650000),
(24, 'BKG2606024', 8, '2026-06-20', '2026-06-22', 1900000, 'Ghi chú tự động', 'CONFIRMED', '2026-06-15 21:09:00', 'Phạm Minh Hùng', 'phạmminhhùng64@gmail.com', '0991332642', '072561557300', 2, 0, 'VNPAY', 'PAID', 1900000),
(25, 'BKG2604025', 37, '2026-04-15', '2026-04-19', 9200000, 'Ghi chú tự động', 'COMPLETED', '2026-04-03 12:44:00', 'Hoàng Đức Khang', 'hoàngđứckhang84@gmail.com', '0949555330', '076668044514', 2, 0, 'CASH', 'PAID', 9200000),
(26, 'BKG2605026', 42, '2026-05-25', '2026-05-28', 7650000, 'Ghi chú tự động', 'CONFIRMED', '2026-05-15 14:40:00', 'Nguyễn Quang Linh', 'nguyễnquanglinh52@gmail.com', '0953481198', '081911347222', 2, 0, 'VNPAY', 'PAID', 7650000),
(27, 'BKG2602027', 21, '2026-02-27', '2026-03-01', 6050000, 'Ghi chú tự động', 'COMPLETED', '2026-02-15 15:18:00', 'Phạm Ngọc Linh', 'phạmngọclinh78@gmail.com', '0925529407', '076221747837', 2, 0, 'VNPAY', 'PAID', 6050000),
(28, 'BKG2605028', 41, '2026-05-25', '2026-05-26', 1600000, 'Ghi chú tự động', 'CONFIRMED', '2026-05-16 10:59:00', 'Hồ Văn Phong', 'hồvănphong35@gmail.com', '0929854548', '080566921940', 2, 0, 'VNPAY', 'PAID', 1600000),
(29, 'BKG2604029', 41, '2026-04-03', '2026-04-05', 4300000, 'Ghi chú tự động', 'COMPLETED', '2026-04-02 16:26:00', 'Hồ Văn Phong', 'hồvănphong35@gmail.com', '0929854548', '080566921940', 2, 0, 'VNPAY', 'PAID', 4300000),
(30, 'BKG2605030', 18, '2026-05-18', '2026-05-21', 4800000, 'Ghi chú tự động', 'CANCELLED', '2026-05-09 12:52:00', 'Bùi Thị Trí', 'bùithịtrí45@gmail.com', '0931944441', '085758139559', 2, 0, 'VNPAY', 'REFUNDED', 0),
(31, 'BKG2606031', 43, '2026-06-06', '2026-06-08', 6400000, 'Ghi chú tự động', 'CONFIRMED', '2026-05-29 13:21:00', 'Hồ Quang Đạt', 'hồquangđạt13@gmail.com', '0944446182', '082757773474', 2, 0, 'VNPAY', 'PAID', 6400000),
(32, 'BKG2603032', 21, '2026-03-21', '2026-03-23', 7550000, 'Ghi chú tự động', 'COMPLETED', '2026-03-17 21:49:00', 'Phạm Ngọc Linh', 'phạmngọclinh78@gmail.com', '0925529407', '076221747837', 2, 0, 'CREDIT_CARD', 'PAID', 7550000),
(33, 'BKG2603033', 47, '2026-03-09', '2026-03-13', 7900000, 'Ghi chú tự động', 'COMPLETED', '2026-03-06 09:30:00', 'Phạm Hoàng Trí', 'phạmhoàngtrí95@gmail.com', '0941511484', '080343968789', 2, 0, 'CASH', 'PAID', 7900000),
(34, 'BKG2606034', 32, '2026-06-19', '2026-06-20', 1900000, 'Ghi chú tự động', 'CONFIRMED', '2026-06-15 18:43:00', 'Đặng Minh Hân', 'đặngminhhân48@gmail.com', '0972909480', '089988676070', 2, 0, 'CREDIT_CARD', 'PAID', 1900000),
(35, 'BKG2602035', 49, '2026-02-26', '2026-03-02', 5050000, 'Ghi chú tự động', 'COMPLETED', '2026-02-21 22:01:00', 'Hồ Đức Kha', 'hồđứckha46@gmail.com', '0940785405', '083787629633', 2, 0, 'CASH', 'PAID', 5050000),
(36, 'BKG2604036', 44, '2026-04-03', '2026-04-07', 6400000, 'Ghi chú tự động', 'CANCELLED', '2026-03-31 11:29:00', 'Trần Thị Trang', 'trầnthịtrang54@gmail.com', '0958326160', '084232135711', 2, 0, 'CASH', 'UNPAID', 0),
(37, 'BKG2604037', 30, '2026-04-15', '2026-04-20', 10800000, 'Ghi chú tự động', 'COMPLETED', '2026-04-07 13:37:00', 'Đặng Hữu Tuấn', 'đặnghữutuấn11@gmail.com', '0909736572', '089148190503', 2, 0, 'VNPAY', 'PAID', 10800000),
(38, 'BKG2605038', 43, '2026-05-13', '2026-05-16', 2850000, 'Ghi chú tự động', 'CONFIRMED', '2026-04-29 18:49:00', 'Hồ Quang Đạt', 'hồquangđạt13@gmail.com', '0944446182', '082757773474', 2, 0, 'CASH', 'PAID', 2850000),
(39, 'BKG2603039', 19, '2026-03-31', '2026-04-05', 4750000, 'Ghi chú tự động', 'COMPLETED', '2026-03-27 18:12:00', 'Lý Ngọc Phong', 'lýngọcphong34@gmail.com', '0954634663', '070405126228', 2, 0, 'CREDIT_CARD', 'PAID', 4750000),
(40, 'BKG2605040', 38, '2026-05-05', '2026-05-07', 2200000, 'Ghi chú tự động', 'COMPLETED', '2026-04-30 13:47:00', 'Đặng Xuân Khang', 'đặngxuânkhang36@gmail.com', '0948024342', '077224421430', 2, 0, 'VNPAY', 'PAID', 2200000),
(41, 'BKG2604041', 31, '2026-04-17', '2026-04-20', 4800000, 'Ghi chú tự động', 'COMPLETED', '2026-04-09 09:09:00', 'Phan Đức Mai', 'phanđứcmai54@gmail.com', '0917778019', '073783282817', 2, 0, 'VNPAY', 'PAID', 4800000),
(42, 'BKG2604042', 44, '2026-04-01', '2026-04-05', 18000000, 'Ghi chú tự động', 'COMPLETED', '2026-03-23 13:58:00', 'Trần Thị Trang', 'trầnthịtrang54@gmail.com', '0958326160', '084232135711', 2, 0, 'CASH', 'PAID', 18000000),
(43, 'BKG2602043', 9, '2026-02-12', '2026-02-13', 5600000, 'Ghi chú tự động', 'COMPLETED', '2026-02-04 09:06:00', 'Dương Đức Mai', 'dươngđứcmai11@gmail.com', '0974252722', '081814930192', 2, 0, 'CREDIT_CARD', 'PAID', 5600000),
(44, 'BKG2602044', 42, '2026-02-26', '2026-03-02', 11150000, 'Ghi chú tự động', 'COMPLETED', '2026-02-21 08:44:00', 'Nguyễn Quang Linh', 'nguyễnquanglinh52@gmail.com', '0953481198', '081911347222', 2, 0, 'CREDIT_CARD', 'PAID', 11150000),
(45, 'BKG2602045', 30, '2026-02-24', '2026-02-26', 2350000, 'Ghi chú tự động', 'COMPLETED', '2026-02-14 08:03:00', 'Đặng Hữu Tuấn', 'đặnghữutuấn11@gmail.com', '0909736572', '089148190503', 2, 0, 'VNPAY', 'PAID', 2350000),
(46, 'BKG2603046', 22, '2026-03-10', '2026-03-15', 4750000, 'Ghi chú tự động', 'COMPLETED', '2026-02-24 10:08:00', 'Dương Ngọc Thảo', 'dươngngọcthảo80@gmail.com', '0959476001', '070420514789', 2, 0, 'CASH', 'PAID', 4750000),
(47, 'BKG2604047', 12, '2026-04-09', '2026-04-10', 5700000, 'Ghi chú tự động', 'COMPLETED', '2026-04-02 16:07:00', 'Huỳnh Đức Trí', 'huỳnhđứctrí86@gmail.com', '0900076758', '084277141563', 2, 0, 'CASH', 'PAID', 5700000),
(48, 'BKG2602048', 44, '2026-02-28', '2026-03-04', 18850000, 'Ghi chú tự động', 'COMPLETED', '2026-02-20 09:57:00', 'Trần Thị Trang', 'trầnthịtrang54@gmail.com', '0958326160', '084232135711', 2, 0, 'CASH', 'PAID', 18850000),
(49, 'BKG2605049', 33, '2026-05-22', '2026-05-23', 3200000, 'Ghi chú tự động', 'PENDING', '2026-05-20 21:41:00', 'Đặng Quang Hiếu', 'đặngquanghiếu43@gmail.com', '0918024248', '076671044759', 2, 0, 'VNPAY', 'UNPAID', 0),
(50, 'BKG2605050', 15, '2026-05-17', '2026-05-20', 4800000, 'Ghi chú tự động', 'PENDING', '2026-05-10 14:46:00', 'Ngô Ngọc Đạt', 'ngôngọcđạt98@gmail.com', '0997969689', '084223713178', 2, 0, 'CASH', 'UNPAID', 0),
(51, 'BKG2603051', 24, '2026-03-12', '2026-03-16', 7900000, 'Ghi chú tự động', 'COMPLETED', '2026-02-26 09:05:00', 'Huỳnh Thu Kha', 'huỳnhthukha43@gmail.com', '0952401521', '086257006797', 2, 0, 'VNPAY', 'PAID', 7900000),
(52, 'BKG2604052', 19, '2026-04-21', '2026-04-24', 2850000, 'Ghi chú tự động', 'COMPLETED', '2026-04-12 11:09:00', 'Lý Ngọc Phong', 'lýngọcphong34@gmail.com', '0954634663', '070405126228', 2, 0, 'VNPAY', 'PAID', 2850000),
(53, 'BKG2605053', 15, '2026-05-21', '2026-05-26', 16000000, 'Ghi chú tự động', 'CANCELLED', '2026-05-07 17:39:00', 'Ngô Ngọc Đạt', 'ngôngọcđạt98@gmail.com', '0997969689', '084223713178', 2, 0, 'CASH', 'UNPAID', 0),
(54, 'BKG2604054', 43, '2026-04-10', '2026-04-11', 3600000, 'Ghi chú tự động', 'COMPLETED', '2026-03-29 20:19:00', 'Hồ Quang Đạt', 'hồquangđạt13@gmail.com', '0944446182', '082757773474', 2, 0, 'VNPAY', 'PAID', 3600000),
(55, 'BKG2604055', 30, '2026-04-29', '2026-05-01', 10900000, 'Ghi chú tự động', 'COMPLETED', '2026-04-17 13:49:00', 'Đặng Hữu Tuấn', 'đặnghữutuấn11@gmail.com', '0909736572', '089148190503', 2, 0, 'VNPAY', 'PAID', 10900000),
(56, 'BKG2602056', 4, '2026-02-21', '2026-02-24', 6500000, 'Ghi chú tự động', 'COMPLETED', '2026-02-14 15:38:00', 'Vũ Quang Tuấn', 'vũquangtuấn39@gmail.com', '0907507864', '073529615275', 2, 0, 'VNPAY', 'PAID', 6500000),
(57, 'BKG2605057', 15, '2026-05-13', '2026-05-18', 8000000, 'Ghi chú tự động', 'CONFIRMED', '2026-05-09 12:13:00', 'Ngô Ngọc Đạt', 'ngôngọcđạt98@gmail.com', '0997969689', '084223713178', 2, 0, 'VNPAY', 'PAID', 8000000),
(58, 'BKG2606058', 1, '2026-06-08', '2026-06-12', 12800000, 'Ghi chú tự động', 'CONFIRMED', '2026-06-01 16:45:00', 'Vũ Hoàng Thảo', 'vũhoàngthảo22@gmail.com', '0931244663', '080222564311', 2, 0, 'VNPAY', 'PAID', 12800000),
(59, 'BKG2602059', 48, '2026-02-11', '2026-02-15', 16550000, 'Ghi chú tự động', 'COMPLETED', '2026-02-09 21:20:00', 'Hoàng Ngọc Ngọc', 'hoàngngọcngọc58@gmail.com', '0989245317', '078172487590', 2, 0, 'CREDIT_CARD', 'PAID', 16550000),
(60, 'BKG2604060', 20, '2026-04-28', '2026-04-30', 9400000, 'Ghi chú tự động', 'COMPLETED', '2026-04-25 09:32:00', 'Ngô Thu Hân', 'ngôthuhân16@gmail.com', '0997854904', '070422701550', 2, 0, 'CREDIT_CARD', 'PAID', 9400000),
(61, 'BK617911', 51, '2026-05-10', '2026-05-11', 950000, '', 'CONFIRMED', '2026-05-10 14:36:57', 'do kha', 'dvk2k333@gmail.com', '0385226320', '079200001111', 2, 0, 'VNPAY', 'PAID', 950000);

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
(1, 16, 950000),
(2, 10, 950000),
(3, 36, 3200000),
(4, 31, 1600000),
(5, 19, 1600000),
(6, 27, 1600000),
(7, 27, 1600000),
(8, 14, 950000),
(9, 6, 950000),
(10, 37, 3200000),
(11, 25, 1600000),
(11, 26, 1600000),
(12, 1, 950000),
(13, 16, 950000),
(14, 21, 1600000),
(15, 16, 950000),
(16, 38, 3200000),
(17, 18, 1600000),
(18, 14, 950000),
(19, 32, 1600000),
(19, 41, 4500000),
(20, 31, 1600000),
(21, 39, 4500000),
(22, 28, 1600000),
(23, 39, 4500000),
(24, 11, 950000),
(25, 18, 1600000),
(26, 6, 950000),
(26, 31, 1600000),
(27, 26, 1600000),
(28, 32, 1600000),
(29, 8, 950000),
(30, 20, 1600000),
(31, 35, 3200000),
(32, 21, 1600000),
(33, 17, 1600000),
(34, 6, 950000),
(34, 15, 950000),
(35, 4, 950000),
(36, 30, 1600000),
(37, 28, 1600000),
(38, 4, 950000),
(39, 9, 950000),
(40, 13, 950000),
(41, 15, 950000),
(42, 42, 4500000),
(43, 35, 3200000),
(44, 29, 1600000),
(45, 16, 950000),
(46, 12, 950000),
(47, 31, 1600000),
(48, 39, 4500000),
(49, 36, 3200000),
(50, 28, 1600000),
(51, 24, 1600000),
(52, 15, 950000),
(53, 36, 3200000),
(54, 1, 950000),
(54, 23, 1600000),
(55, 6, 950000),
(55, 39, 4500000),
(56, 18, 1600000),
(57, 17, 1600000),
(58, 36, 3200000),
(59, 37, 3200000),
(60, 34, 3200000),
(61, 3, 950000);

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
(1, 1, 4, 1, 450000, '2026-02-22 08:00:00'),
(2, 1, 7, 1, 1200000, '2026-02-22 15:00:00'),
(3, 3, 2, 2, 850000, '2026-03-01 20:00:00'),
(4, 5, 5, 2, 400000, '2026-04-14 16:00:00'),
(5, 7, 4, 2, 450000, '2026-02-09 08:00:00'),
(6, 7, 8, 2, 200000, '2026-02-08 18:00:00'),
(7, 7, 2, 3, 850000, '2026-02-09 19:00:00'),
(8, 7, 3, 1, 350000, '2026-02-09 10:00:00'),
(9, 9, 1, 1, 500000, '2026-05-10 11:00:00'),
(10, 9, 6, 3, 100000, '2026-05-09 20:00:00'),
(11, 9, 5, 3, 400000, '2026-05-09 20:00:00'),
(12, 10, 8, 3, 200000, '2026-03-24 20:00:00'),
(13, 11, 2, 3, 850000, '2026-03-01 09:00:00'),
(14, 12, 8, 2, 200000, '2026-05-03 19:00:00'),
(15, 12, 1, 1, 500000, '2026-05-03 10:00:00'),
(16, 12, 4, 3, 450000, '2026-05-04 18:00:00'),
(17, 14, 8, 1, 200000, '2026-04-06 20:00:00'),
(18, 18, 5, 3, 400000, '2026-03-24 12:00:00'),
(19, 18, 6, 1, 100000, '2026-03-22 12:00:00'),
(20, 18, 8, 1, 200000, '2026-03-23 10:00:00'),
(21, 22, 1, 3, 500000, '2026-05-09 20:00:00'),
(22, 22, 5, 1, 400000, '2026-05-10 12:00:00'),
(23, 23, 5, 2, 400000, '2026-04-04 19:00:00'),
(24, 23, 1, 2, 500000, '2026-04-03 18:00:00'),
(25, 23, 2, 1, 850000, '2026-04-04 20:00:00'),
(26, 25, 8, 1, 200000, '2026-04-18 19:00:00'),
(27, 25, 4, 2, 450000, '2026-04-17 08:00:00'),
(28, 25, 1, 1, 500000, '2026-04-16 18:00:00'),
(29, 25, 5, 3, 400000, '2026-04-15 20:00:00'),
(30, 27, 1, 2, 500000, '2026-02-28 09:00:00'),
(31, 27, 4, 2, 450000, '2026-02-27 18:00:00'),
(32, 27, 8, 3, 200000, '2026-02-28 14:00:00'),
(33, 27, 3, 1, 350000, '2026-02-27 16:00:00'),
(34, 29, 2, 2, 850000, '2026-04-04 16:00:00'),
(35, 29, 6, 3, 100000, '2026-04-04 14:00:00'),
(36, 29, 8, 2, 200000, '2026-04-04 11:00:00'),
(37, 32, 7, 3, 1200000, '2026-03-21 15:00:00'),
(38, 32, 4, 1, 450000, '2026-03-21 16:00:00'),
(39, 32, 6, 3, 100000, '2026-03-22 09:00:00'),
(40, 33, 7, 1, 1200000, '2026-03-11 18:00:00'),
(41, 33, 6, 3, 100000, '2026-03-12 13:00:00'),
(42, 35, 6, 2, 100000, '2026-02-27 11:00:00'),
(43, 35, 3, 3, 350000, '2026-03-01 17:00:00'),
(44, 37, 8, 2, 200000, '2026-04-16 14:00:00'),
(45, 37, 7, 2, 1200000, '2026-04-15 11:00:00'),
(46, 40, 6, 3, 100000, '2026-05-06 10:00:00'),
(47, 41, 6, 1, 100000, '2026-04-18 16:00:00'),
(48, 41, 1, 1, 500000, '2026-04-18 13:00:00'),
(49, 41, 4, 3, 450000, '2026-04-19 18:00:00'),
(50, 43, 7, 2, 1200000, '2026-02-12 18:00:00'),
(51, 44, 4, 1, 450000, '2026-02-28 16:00:00'),
(52, 44, 7, 3, 1200000, '2026-02-28 08:00:00'),
(53, 44, 3, 2, 350000, '2026-02-28 11:00:00'),
(54, 45, 4, 1, 450000, '2026-02-24 17:00:00'),
(55, 47, 6, 1, 100000, '2026-04-09 16:00:00'),
(56, 47, 5, 1, 400000, '2026-04-09 19:00:00'),
(57, 47, 7, 3, 1200000, '2026-04-09 15:00:00'),
(58, 48, 2, 1, 850000, '2026-03-02 17:00:00'),
(59, 51, 1, 3, 500000, '2026-03-14 18:00:00'),
(60, 54, 3, 3, 350000, '2026-04-10 09:00:00'),
(61, 56, 2, 2, 850000, '2026-02-22 09:00:00'),
(62, 59, 7, 2, 1200000, '2026-02-11 13:00:00'),
(63, 59, 3, 1, 350000, '2026-02-14 19:00:00'),
(64, 59, 1, 2, 500000, '2026-02-11 14:00:00'),
(65, 60, 4, 3, 450000, '2026-04-28 11:00:00'),
(66, 60, 7, 1, 1200000, '2026-04-28 12:00:00'),
(67, 60, 3, 1, 350000, '2026-04-28 17:00:00'),
(68, 60, 6, 1, 100000, '2026-04-28 10:00:00');

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
(1, 'Hoàng Tú', 'tu.hoang@gmail.com', 'Hỏi về tiệc cưới', 'Khách sạn có nhận tổ chức tiệc cưới quy mô 100 khách không?', 'RESOLVED', '2026-03-29 23:42:07'),
(2, 'Lý Mạc Sầu', 'lymacsau@gmail.com', 'Thất lạc đồ', 'Tôi để quên áo khoác ở phòng 101 ngày 22/3, xin kiểm tra giúp.', 'RESOLVED', '2026-03-29 23:42:07'),
(3, 'Đỗ Khả', 'admin@gmail.com', 'Hỏi đáp Dịch vụ/Tiện ích', 'Xin chào', 'RESOLVED', '2026-05-08 20:36:49'),
(4, 'Trần Anh Tâm', 'anhtam@example.com', 'Báo giá khách đoàn', 'Cho mình xin báo giá 15 phòng Standard vào dịp lễ 30/4', 'UNREAD', '2026-05-09 10:15:00'),
(5, 'Phạm Quỳnh', 'quynhpham@example.com', 'Phàn nàn dịch vụ dọn phòng', 'Phòng 204 dọn chưa sạch', 'UNREAD', '2026-05-10 08:20:00');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `guests`
--

CREATE TABLE `guests` (
  `id` int(11) NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `phone_number` varchar(20) NOT NULL,
  `email` varchar(100) DEFAULT NULL,
  `id_card` varchar(20) DEFAULT NULL,
  `birth_date` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `guests`
--

INSERT INTO `guests` (`id`, `full_name`, `phone_number`, `email`, `id_card`, `birth_date`) VALUES
(1, 'Vũ Hoàng Thảo', '0931244663', 'vũhoàngthảo22@gmail.com', '080222564311', '1984-11-27'),
(2, 'Đỗ Minh Thành', '0947683626', 'đỗminhthành36@gmail.com', '081468315044', '1992-11-21'),
(3, 'Lê Thái Hùng', '0971691040', 'lêtháihùng41@gmail.com', '083586710255', '1982-05-21'),
(4, 'Vũ Quang Tuấn', '0907507864', 'vũquangtuấn39@gmail.com', '073529615275', '1995-06-13'),
(5, 'Võ Thị Linh', '0976125617', 'võthịlinh50@gmail.com', '085029083825', '1998-11-15'),
(6, 'Hoàng Hoàng Nam', '0933101783', 'hoànghoàngnam81@gmail.com', '080904824424', '1993-10-14'),
(7, 'Hồ Xuân Lan', '0918566572', 'hồxuânlan75@gmail.com', '072119634399', '1994-01-28'),
(8, 'Phạm Minh Hùng', '0991332642', 'phạmminhhùng64@gmail.com', '072561557300', '1982-07-20'),
(9, 'Dương Đức Mai', '0974252722', 'dươngđứcmai11@gmail.com', '081814930192', '1994-11-11'),
(10, 'Phạm Hoàng Ngọc', '0921227574', 'phạmhoàngngọc68@gmail.com', '081680939531', '1986-03-17'),
(11, 'Phạm Quang Hoa', '0985758349', 'phạmquanghoa74@gmail.com', '076910474439', '1974-06-25'),
(12, 'Huỳnh Đức Trí', '0900076758', 'huỳnhđứctrí86@gmail.com', '084277141563', '1970-02-12'),
(13, 'Đặng Ngọc Khang', '0932329237', 'đặngngọckhang82@gmail.com', '074067116918', '1972-12-16'),
(14, 'Lê Đức Nam', '0917232410', 'lêđứcnam94@gmail.com', '076656355760', '1978-09-28'),
(15, 'Ngô Ngọc Đạt', '0997969689', 'ngôngọcđạt98@gmail.com', '084223713178', '1991-11-12'),
(16, 'Dương Đức Hân', '0916240908', 'dươngđứchân41@gmail.com', '070965067727', '1980-01-19'),
(17, 'Vũ Thái Lan', '0900965138', 'vũtháilan19@gmail.com', '074547828192', '1972-01-28'),
(18, 'Bùi Thị Trí', '0931944441', 'bùithịtrí45@gmail.com', '085758139559', '1976-09-05'),
(19, 'Lý Ngọc Phong', '0954634663', 'lýngọcphong34@gmail.com', '070405126228', '1991-07-12'),
(20, 'Ngô Thu Hân', '0997854904', 'ngôthuhân16@gmail.com', '070422701550', '1982-12-11'),
(21, 'Phạm Ngọc Linh', '0925529407', 'phạmngọclinh78@gmail.com', '076221747837', '1983-03-09'),
(22, 'Dương Ngọc Thảo', '0959476001', 'dươngngọcthảo80@gmail.com', '070420514789', '1990-09-27'),
(23, 'Nguyễn Thị Lan', '0922321899', 'nguyễnthịlan62@gmail.com', '084970714647', '1976-07-02'),
(24, 'Huỳnh Thu Kha', '0952401521', 'huỳnhthukha43@gmail.com', '086257006797', '1979-07-23'),
(25, 'Lý Minh Linh', '0939823450', 'lýminhlinh37@gmail.com', '074160575046', '1988-12-18'),
(26, 'Trần Xuân Khang', '0906729990', 'trầnxuânkhang84@gmail.com', '089227660266', '1999-09-06'),
(27, 'Trần Đức Thảo', '0924941004', 'trầnđứcthảo18@gmail.com', '072555656321', '1991-04-13'),
(28, 'Phạm Thái Lan', '0977701200', 'phạmtháilan86@gmail.com', '087350558334', '1972-07-22'),
(29, 'Bùi Hoàng Linh', '0989889098', 'bùihoànglinh50@gmail.com', '079615082973', '1982-03-22'),
(30, 'Đặng Hữu Tuấn', '0909736572', 'đặnghữutuấn11@gmail.com', '089148190503', '1988-02-03'),
(31, 'Phan Đức Mai', '0917778019', 'phanđứcmai54@gmail.com', '073783282817', '1998-04-12'),
(32, 'Đặng Minh Hân', '0972909480', 'đặngminhhân48@gmail.com', '089988676070', '1970-11-27'),
(33, 'Đặng Quang Hiếu', '0918024248', 'đặngquanghiếu43@gmail.com', '076671044759', '1978-05-20'),
(34, 'Phan Xuân Linh', '0992274302', 'phanxuânlinh91@gmail.com', '082253167242', '1986-08-09'),
(35, 'Trần Thị Ngọc', '0937135391', 'trầnthịngọc15@gmail.com', '078605163214', '1994-03-21'),
(36, 'Võ Minh Hân', '0974045292', 'võminhhân64@gmail.com', '072409076656', '1973-02-23'),
(37, 'Hoàng Đức Khang', '0949555330', 'hoàngđứckhang84@gmail.com', '076668044514', '1983-03-02'),
(38, 'Đặng Xuân Khang', '0948024342', 'đặngxuânkhang36@gmail.com', '077224421430', '1991-02-12'),
(39, 'Ngô Thái Nam', '0931774346', 'ngôtháinam30@gmail.com', '077777205338', '1998-07-01'),
(40, 'Huỳnh Xuân Ngọc', '0989913412', 'huỳnhxuânngọc41@gmail.com', '075440889099', '1995-12-04'),
(41, 'Hồ Văn Phong', '0929854548', 'hồvănphong35@gmail.com', '080566921940', '1979-04-08'),
(42, 'Nguyễn Quang Linh', '0953481198', 'nguyễnquanglinh52@gmail.com', '081911347222', '1981-11-17'),
(43, 'Hồ Quang Đạt', '0944446182', 'hồquangđạt13@gmail.com', '082757773474', '1975-10-09'),
(44, 'Trần Thị Trang', '0958326160', 'trầnthịtrang54@gmail.com', '084232135711', '1989-09-04'),
(45, 'Hồ Thái Linh', '0934188276', 'hồtháilinh15@gmail.com', '085929111504', '1970-09-26'),
(46, 'Phan Xuân Ngọc', '0909391725', 'phanxuânngọc95@gmail.com', '082544615301', '1989-06-22'),
(47, 'Phạm Hoàng Trí', '0941511484', 'phạmhoàngtrí95@gmail.com', '080343968789', '1982-12-10'),
(48, 'Hoàng Ngọc Ngọc', '0989245317', 'hoàngngọcngọc58@gmail.com', '078172487590', '1989-10-10'),
(49, 'Hồ Đức Kha', '0940785405', 'hồđứckha46@gmail.com', '083787629633', '1995-10-20'),
(50, 'Bùi Hữu Hân', '0959345683', 'bùihữuhân96@gmail.com', '088097709722', '1985-12-06'),
(51, 'do kha', '0385226320', 'dvk2k333@gmail.com', '079200001111', '2002-06-10');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `reviews`
--

CREATE TABLE `reviews` (
  `id` int(11) NOT NULL,
  `guest_id` int(11) NOT NULL,
  `booking_id` int(11) NOT NULL,
  `room_id` int(11) NOT NULL,
  `rating` int(11) NOT NULL COMMENT 'Số sao từ 1 đến 5',
  `comment` text DEFAULT NULL COMMENT 'Nội dung đánh giá',
  `status` tinyint(4) DEFAULT 1 COMMENT '0: Ẩn/Spam, 1: Hiển thị',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `reviews`
--

INSERT INTO `reviews` (`id`, `guest_id`, `booking_id`, `room_id`, `rating`, `comment`, `status`, `created_at`) VALUES
(1, 50, 3, 36, 5, 'Bữa sáng ngon, nhân viên nhiệt tình.', 1, '2026-03-07 17:00:00'),
(2, 16, 5, 19, 4, 'Rất hài lòng với trải nghiệm tại OmniStay.', 1, '2026-04-18 17:00:00'),
(3, 38, 7, 27, 5, 'Phòng ốc tuyệt vời, dịch vụ xuất sắc!', 1, '2026-02-11 17:00:00'),
(4, 16, 10, 37, 5, 'Phòng ốc tuyệt vời, dịch vụ xuất sắc!', 1, '2026-03-26 17:00:00'),
(5, 20, 11, 25, 5, 'Phòng ốc tuyệt vời, dịch vụ xuất sắc!', 1, '2026-03-09 17:00:00'),
(6, 29, 14, 21, 5, 'Bữa sáng ngon, nhân viên nhiệt tình.', 1, '2026-04-12 17:00:00'),
(7, 37, 20, 31, 2, 'Wifi yếu quá không làm việc được.', 0, '2026-04-19 17:00:00'),
(8, 11, 23, 39, 5, 'Rất hài lòng với trải nghiệm tại OmniStay.', 1, '2026-04-08 17:00:00'),
(9, 37, 25, 18, 1, 'Thái độ nhân viên lễ tân chưa tốt.', 0, '2026-04-23 17:00:00'),
(10, 41, 29, 8, 3, 'Wifi yếu quá không làm việc được.', 1, '2026-04-05 17:00:00'),
(11, 21, 32, 21, 5, 'View từ ban công rất đẹp, không gian yên tĩnh.', 1, '2026-03-23 17:00:00'),
(12, 49, 35, 4, 3, 'Thái độ nhân viên lễ tân chưa tốt.', 1, '2026-03-06 17:00:00'),
(13, 30, 37, 28, 4, 'Bữa sáng ngon, nhân viên nhiệt tình.', 1, '2026-04-20 17:00:00'),
(14, 19, 39, 9, 4, 'View từ ban công rất đẹp, không gian yên tĩnh.', 1, '2026-04-05 17:00:00'),
(15, 31, 41, 15, 5, 'Bữa sáng ngon, nhân viên nhiệt tình.', 1, '2026-04-20 17:00:00'),
(16, 44, 42, 42, 5, 'View từ ban công rất đẹp, không gian yên tĩnh.', 1, '2026-04-05 17:00:00'),
(17, 9, 43, 35, 5, 'Rất hài lòng với trải nghiệm tại OmniStay.', 1, '2026-02-16 17:00:00'),
(18, 22, 46, 12, 1, 'Khăn tắm có mùi ẩm, cần cải thiện.', 0, '2026-03-15 17:00:00'),
(19, 12, 47, 31, 5, 'View từ ban công rất đẹp, không gian yên tĩnh.', 1, '2026-04-13 17:00:00'),
(20, 44, 48, 39, 4, 'Bữa sáng ngon, nhân viên nhiệt tình.', 1, '2026-03-07 17:00:00'),
(21, 24, 51, 24, 5, 'View từ ban công rất đẹp, không gian yên tĩnh.', 1, '2026-03-16 17:00:00'),
(22, 19, 52, 15, 3, 'Khăn tắm có mùi ẩm, cần cải thiện.', 1, '2026-04-28 17:00:00'),
(23, 43, 54, 23, 1, 'Thái độ nhân viên lễ tân chưa tốt.', 0, '2026-04-14 17:00:00'),
(24, 4, 56, 18, 4, 'Bữa sáng ngon, nhân viên nhiệt tình.', 1, '2026-02-24 17:00:00'),
(25, 48, 59, 37, 5, 'Phòng ốc tuyệt vời, dịch vụ xuất sắc!', 1, '2026-02-18 17:00:00'),
(26, 20, 60, 34, 4, 'View từ ban công rất đẹp, không gian yên tĩnh.', 1, '2026-05-04 17:00:00');

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
(2, '102', 1, 'MAINTENANCE'),
(3, '103', 1, 'OCCUPIED'),
(4, '104', 1, 'AVAILABLE'),
(5, '105', 1, 'AVAILABLE'),
(6, '106', 1, 'OCCUPIED'),
(7, '107', 1, 'AVAILABLE'),
(8, '108', 1, 'CLEANING'),
(9, '201', 1, 'AVAILABLE'),
(10, '202', 1, 'MAINTENANCE'),
(11, '203', 1, 'AVAILABLE'),
(12, '204', 1, 'AVAILABLE'),
(13, '205', 1, 'MAINTENANCE'),
(14, '206', 1, 'AVAILABLE'),
(15, '207', 1, 'AVAILABLE'),
(16, '208', 1, 'AVAILABLE'),
(17, '301', 2, 'AVAILABLE'),
(18, '302', 2, 'AVAILABLE'),
(19, '303', 2, 'AVAILABLE'),
(20, '304', 2, 'MAINTENANCE'),
(21, '305', 2, 'AVAILABLE'),
(22, '306', 2, 'AVAILABLE'),
(23, '307', 2, 'AVAILABLE'),
(24, '308', 2, 'AVAILABLE'),
(25, '401', 2, 'AVAILABLE'),
(26, '402', 2, 'AVAILABLE'),
(27, '403', 2, 'CLEANING'),
(28, '404', 2, 'OCCUPIED'),
(29, '405', 2, 'AVAILABLE'),
(30, '406', 2, 'AVAILABLE'),
(31, '407', 2, 'AVAILABLE'),
(32, '408', 2, 'AVAILABLE'),
(33, '501', 3, 'AVAILABLE'),
(34, '502', 3, 'AVAILABLE'),
(35, '503', 3, 'AVAILABLE'),
(36, '504', 3, 'AVAILABLE'),
(37, '505', 3, 'AVAILABLE'),
(38, '506', 3, 'AVAILABLE'),
(39, '601', 4, 'AVAILABLE'),
(40, '602', 4, 'AVAILABLE'),
(41, '603', 4, 'AVAILABLE'),
(42, '604', 4, 'MAINTENANCE');

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
(1, 'STANDARD', 950000, 2, 'Sàn gỗ sồi tự nhiên, thiết kế tối giản, view nhìn ra trung tâm thành phố nhộn nhịp.', 'https://images.unsplash.com/photo-1590490360182-c33d57733427?w=600&q=80'),
(2, 'DELUXE', 1600000, 2, 'Ban công rộng đón gió sông Hậu, bồn tắm sứ thủ công và nệm tiêu chuẩn 5 sao.', 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=600&q=80'),
(3, 'PREMIUM', 3200000, 3, 'Phòng khách hoàng gia, nội thất khảm trai tinh xảo. Miễn phí trà chiều và đưa đón sân bay.', 'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=600&q=80'),
(4, 'FAMILY SUITE', 4500000, 4, 'Căn hộ gia đình 2 phòng ngủ, có bếp nhỏ và khu vực sinh hoạt chung rộng rãi.', 'https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=600&q=80');

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
(6, 'Giặt ủi tiêu chuẩn', 100000, 'Bộ'),
(7, 'Set Ăn tối lãng mạn tại phòng', 1200000, 'Set'),
(8, 'Thuê xe máy tay ga', 200000, 'Ngày');

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
(1, 'Đỗ Văn Kha', 'admin@omnistay.vn', '123456', 'ADMIN', '2026-03-01 08:00:00'),
(2, 'Nguyễn Phú Khang', 'nguyenphukhang@omnistay.vn', '123456', 'RECEPTIONIST', '2026-03-01 08:00:00'),
(3, 'Đoàn Như Thảo', 'doannhuthao@omnistay.vn', '123456', 'RECEPTIONIST', '2026-03-01 08:00:00'),
(4, 'Trần Minh Hiếu', 'tranminhhieu@omnistay.vn', '123456', 'RECEPTIONIST', '2026-03-01 08:00:00');

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
-- Chỉ mục cho bảng `reviews`
--
ALTER TABLE `reviews`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_booking_review` (`booking_id`),
  ADD KEY `fk_review_guest` (`guest_id`),
  ADD KEY `fk_review_room` (`room_id`);

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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=62;

--
-- AUTO_INCREMENT cho bảng `booking_services`
--
ALTER TABLE `booking_services`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=69;

--
-- AUTO_INCREMENT cho bảng `contacts`
--
ALTER TABLE `contacts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT cho bảng `guests`
--
ALTER TABLE `guests`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=52;

--
-- AUTO_INCREMENT cho bảng `reviews`
--
ALTER TABLE `reviews`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT cho bảng `rooms`
--
ALTER TABLE `rooms`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=43;

--
-- AUTO_INCREMENT cho bảng `room_types`
--
ALTER TABLE `room_types`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT cho bảng `services`
--
ALTER TABLE `services`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT cho bảng `staff`
--
ALTER TABLE `staff`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

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
-- Các ràng buộc cho bảng `reviews`
--
ALTER TABLE `reviews`
  ADD CONSTRAINT `fk_review_booking` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_review_guest` FOREIGN KEY (`guest_id`) REFERENCES `guests` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_review_room` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `rooms`
--
ALTER TABLE `rooms`
  ADD CONSTRAINT `rooms_ibfk_1` FOREIGN KEY (`room_type_id`) REFERENCES `room_types` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
