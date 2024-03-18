/*
SQLyog Community v13.1.7 (64 bit)
MySQL - 10.4.20-MariaDB : Database - panabohrmdb
*********************************************************************
*/

/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
CREATE DATABASE /*!32312 IF NOT EXISTS*/`panabohrmdb` /*!40100 DEFAULT CHARACTER SET utf8mb4 */;

USE `panabohrmdb`;

/*Table structure for table `attendance_scanlogs` */

DROP TABLE IF EXISTS `attendance_scanlogs`;

CREATE TABLE `attendance_scanlogs` (
  `logs_id` varchar(100) DEFAULT NULL,
  `event_id` varchar(100) DEFAULT NULL,
  `Employeeid` varchar(100) DEFAULT NULL,
  `logs_date` varchar(100) DEFAULT NULL,
  `logs_time` varchar(100) DEFAULT NULL,
  `timestamp` varchar(100) DEFAULT NULL,
  `scanned_by` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/*Data for the table `attendance_scanlogs` */

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
