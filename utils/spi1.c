/*
 * =====================================================================================
 *
 *       Filename:  spi1.c
 *
 *    Description:  
 *
 *        Version:  1.0
 *        Created:  09/24/2017 03:47:34 PM
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  Yair Gadelov (yg), yair.gadelov@gmail.com
 *        Company:  Israel
 *
 * =====================================================================================
 */

//https://raw.githubusercontent.com/raspberrypi/linux/rpi-3.10.y/Documentation/spi/spidev_test.c
//https://www.kernel.org/doc/Documentation/spi/spi-summary
#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <linux/types.h>
#include <linux/spi/spidev.h>
#include <errno.h>


#define ARRAY_SIZE(array) sizeof(array)/sizeof(array[0])

// SPI register API
static uint32_t speed = 25000000;
int transfer(char const *tx, char *rx, size_t len)
{
	int ret = -1;
	char *device ="/dev/spidev3.1";
	uint32_t mode = 0;

	struct spi_ioc_transfer tr = {
		.tx_buf = (unsigned long) tx,
		.rx_buf = (unsigned long) rx,
		.len = len,
		.delay_usecs = 20,
		.speed_hz = speed, // 10 MHz
		.bits_per_word = 8,
	};

	int fd;

	// It's actually not necessary to open and close the device file for each
	// transaction, but it's more compact like this

	fd = open(device, O_RDWR);
	if (fd < 0) {
		perror("Can't open device");
		goto quit;
	}

	ret = ioctl(fd, SPI_IOC_WR_MODE32, &mode);
	if (ret == -1) {
		perror("Can't set spi mode");
		goto quit;
	}

	ret = ioctl(fd, SPI_IOC_MESSAGE(1), &tr);
	if (ret < 1) {
		perror("Transfer failed");
		goto quit;
	}

	ret = ioctl(fd, SPI_IOC_WR_MAX_SPEED_HZ, &speed);
	if (ret == -1)
		perror("can't set max speed hz");

	ret = ioctl(fd, SPI_IOC_RD_MAX_SPEED_HZ, &speed);
	if (ret == -1)
		perror("can't get max speed hz");

	ret = 0;

quit:
	close(fd);
	return ret;
}

int main(int argc, char **argv) 
{
	int i,fd;
	char wr_buf1[]={130,87,0x79,130};
	 char wr_buf2[]={0x02,0xbb,0xbb,0x02};
//	 char wr_buf3[]={0x12,0x34,0x56,0x78};

	char rd_buf[4];;

	for (int k=0;k<100;k++) {
	wr_buf1[1] = k+13;
	transfer (wr_buf1,rd_buf,4);
	transfer (wr_buf2,rd_buf,4);
//	transfer (wr_buf3,rd_buf,4);

	for (i=0;i<ARRAY_SIZE(rd_buf);i++) {
		if (i==3) {
		printf("0x%02X  %d", rd_buf[i],rd_buf[i] );
		}
		printf("\n");
		
	}
	}
	return 0;




}
