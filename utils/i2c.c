/*
 * =====================================================================================
 *
 *       Filename:  i2c.c
 *
 *    Description: Implementation of I2C Protocol using bitbang that controls the I2C pins using 
 *                 the FPGA spi module. See ref here: https://en.wikipedia.org/wiki/I%C2%B2C
 *
 *        Version:  1.0
 *        Created:  09/28/2017 11:51:02 AM
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  Yair Gadelov (yg), yair.gadelov@gmail.com
 *        Company:  Israel
 *
 * =====================================================================================
 */

// Hardware-specific support functions that MUST be customized:
#include <stdint.h>
#include <stdbool.h>
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

#define I2CSPEED 100

#define SCL_T  ( 1<<0 )
#define SCL_I  ( 1<<1 )
#define SCL_O  ( 1<<2 )
#define SDA_T  ( 1<<3 )
#define SDA_I  ( 1<<4 )
#define SDA_O  ( 1<<5 )

static	char *device ="/dev/spidev3.1";
static bool started = false; // global data



/**
 * Created  09/28/2017
 * @brief   send command FPGA I2C module using SPI 
 * @param   
 * @return  
 */
static int transfer(char const *tx, char *rx)
{
	int ret = -1;
	uint32_t mode = 0;
	uint32_t speed = 25000000;

	struct spi_ioc_transfer tr = {
		.tx_buf = (unsigned long) tx,
		.rx_buf = (unsigned long) rx,
		.len = 4,
		.delay_usecs = 20,
		.speed_hz = speed, // 10 MHz
		.bits_per_word = 8,
	};

	int fd;

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
//	usleep(1000);
	return ret;
}


void I2C_delay(void);

bool read_SCL(void);  // Return current level of SCL line, 0 or 1

bool read_SDA(void);  // Return current level of SDA line, 0 or 1

void set_SCL(void);   // Do not drive SCL (set pin high-impedance)

void clear_SCL(void); // Actively drive SCL signal low

void set_SDA(void);   // Do not drive SDA (set pin high-impedance)

void clear_SDA(void); // Actively drive SDA signal low

void arbitration_lost(void){};



bool read_SCL(void);  // Return current level of SCL line, 0 or 1



/**
 * Created  09/29/2017
 * @brief   Returns I2C current signals level
 * @param   
 * @return  
 */
char read_signals()
{
	char const tx[]={0,0,0,0};
	char rx[4];
	transfer(tx, rx);
	return rx[3];

}

/**
 * Created  09/29/2017
 * @brief    Return current level of SCL line, 0 or 1
 * @param   
 * @return  
 */
bool read_SCL(void)  {
	char sig = read_signals();
	return (sig&SCL_I>0);
}


/**
 * Created  09/29/2017
 * @brief    Return current level of SDL line, 0 or 1
 * @param   
 * @return  
 */
bool read_SDA(void)  {
	char sig = read_signals();
	return (sig&SDA_I>0);
}


/**
 * Created  09/29/2017
 * @brief   Actively drive SCL signal low
 * @param   
 * @return  
 */
void clear_SCL(void)  {
	char tx[4]={0x80,0,0,0};
	char rx[4];
	char sig = read_signals();
	tx[1] = sig&(~SCL_T);
	transfer(tx, rx);
}

/**
 * Created  09/29/2017
 * @brief   Actively drive SCL signal low
 * @param   
 * @return  
 */
void clear_SDA(void)  {
	char tx[4]={0x80,0,0,0};
	char rx[4];
	char sig = read_signals();
	tx[1] = ( sig&(~SDA_T) );
	transfer(tx, rx);
}


/**
 * Created  09/29/2017
 * @brief  Do not drive SCL (set pin high-impedance) 
 * @param   
 * @return  
 */
void set_SCL(void)  
{
	char tx[4]={0x80,0,0,0};
	char rx[4];
	char sig = read_signals();
	tx[1] = ( sig|(SCL_T) );
	transfer(tx, rx);
}

/**
 * Created  09/29/2017
 * @brief  Do not drive SDA (set pin high-impedance) 
 * @param   
 * @return  
 */
void set_SDA(void)  
{
	char tx[4]={0x80,0,0,0};
	char rx[4];
	char sig = read_signals();
	tx[1] = sig|(SDA_T);
	transfer(tx, rx);
}


void i2c_start_cond(void) {

  if (started) { 

    // if started, do a restart condition

    // set SDA to 1

    set_SDA();

    I2C_delay();

    set_SCL();

    while (read_SCL() == 0) { // Clock stretching

      // You should add timeout to this loop

    }


    // Repeated start setup time, minimum 4.7us

    I2C_delay();

  }

 

  if (read_SDA() == 0) {

    arbitration_lost();

  }


  // SCL is high, set SDA from 1 to 0.

  clear_SDA();

  I2C_delay();

  clear_SCL();

  started = true;

}


void i2c_stop_cond(void) {

  // set SDA to 0

  clear_SDA();

  I2C_delay();


  set_SCL();

  // Clock stretching

  while (read_SCL() == 0) {

    // add timeout to this loop.

  }


  // Stop bit setup time, minimum 4us

  I2C_delay();


  // SCL is high, set SDA from 0 to 1

  set_SDA();

  I2C_delay();


  if (read_SDA() == 0) {

    arbitration_lost();

  }


  started = false;

}


// Write a bit to I2C bus

void i2c_write_bit(bool bit) {

  if (bit) {

    set_SDA();

  } else {

    clear_SDA();

  }


  // SDA change propagation delay

  I2C_delay();


  // Set SCL high to indicate a new valid SDA value is available

  set_SCL();


  // Wait for SDA value to be read by slave, minimum of 4us for standard mode

  I2C_delay();


  while (read_SCL() == 0) { // Clock stretching

    // You should add timeout to this loop

  }


  // SCL is high, now data is valid

  // If SDA is high, check that nobody else is driving SDA

  if (bit && (read_SDA() == 0)) {

    arbitration_lost();

  }


  // Clear the SCL to low in preparation for next change

  clear_SCL();

}


// Read a bit from I2C bus

bool i2c_read_bit(void) {

  bool bit;


  // Let the slave drive data

  set_SDA();


  // Wait for SDA value to be written by slave, minimum of 4us for standard mode

  I2C_delay();


  // Set SCL high to indicate a new valid SDA value is available

  set_SCL();


  while (read_SCL() == 0) { // Clock stretching

    // You should add timeout to this loop

  }


  // Wait for SDA value to be written by slave, minimum of 4us for standard mode

  I2C_delay();


  // SCL is high, read out bit

  bit = read_SDA();


  // Set SCL low in preparation for next operation

  clear_SCL();


  return bit;

}


// Write a byte to I2C bus. Return 0 if ack by the slave.

bool i2c_write_byte(bool send_start,

                    bool send_stop,

                    unsigned char byte) {

  unsigned bit;

  bool     nack;


  if (send_start) {

    i2c_start_cond();

  }


  for (bit = 0; bit < 8; ++bit) {

    i2c_write_bit((byte & 0x80) != 0);

    byte <<= 1;

  }


  nack = i2c_read_bit();
 if (nack==false)
	 printf("fffffffff");

  if (send_stop) {

    i2c_stop_cond();

  }


  return nack;

}


// Read a byte from I2C bus

unsigned char i2c_read_byte(bool nack, bool send_stop) {

  unsigned char byte = 0;

  unsigned char bit;


  for (bit = 0; bit < 8; ++bit) {

    byte = (byte << 1) | i2c_read_bit();

  }


  i2c_write_bit(nack);


  if (send_stop) {

    i2c_stop_cond();

  }


  return byte;

}


void I2C_delay(void) { 

 usleep(10); 
}


/*
 * https://www.nxp.com/docs/en/data-sheet/PCA9555.pdf
 * a0=1;
 * a1=0;
 * a2=0;
 * charn2 reg 1 0-6
 */
int main()
{

	char addr; 
	addr = 0x42;
//	set_SDA();
//	set_SCL();
//	usleep(100000);
	started = true;
//	set_SDA();
//	set_SCL();

	i2c_write_byte( true /*send_start*/, /*send_stop*/ false,addr);
	i2c_write_byte( false /*send_start*/, /*send_stop*/ false,6);
	i2c_write_byte( false /*send_start*/, /*send_stop*/ false,0);
	i2c_write_byte( false /*send_start*/, /*send_stop*/ true,0);
 
//	set_SDA();
//	set_SCL();
//	usleep(100000);	
	started = true;	
	i2c_write_byte( true /*send_start*/, /*send_stop*/ false,addr);
	i2c_write_byte( false /*send_start*/, /*send_stop*/ false,2);
	i2c_write_byte( false /*send_start*/, /*send_stop*/ false,0);
	i2c_write_byte( false /*send_start*/, /*send_stop*/ true,10);



}
