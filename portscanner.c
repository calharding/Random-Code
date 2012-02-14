#include <stdio.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <sys/types.h>
#include <netdb.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>

char *ipaddr;
int lowport, highport;

unsigned int resolvedhost;

/* prototypes... */

void reseed(void);
void usage(char *progname);
unsigned int resolve(char *host);

void usage(char *progname)
{
	system("clear");
	printf("usage: %s <address> <low port> <high port> \n", progname);
	exit(1);
}

main(int argc, char *argv[])
{

	struct sockaddr_in sin;
	int sockdesc, x;

	if (argc < 4)
		usage(argv[0]);

	ipaddr = argv[1];
	lowport = atoi(argv[2]);
	highport = atoi(argv[3]);

	resolvedhost = resolve(ipaddr);

	if (highport > 65535) {
		/* port too high */
		printf("highest possible port is 65535. \n");
		exit(0);
	}
	if (lowport < 0) {
		/* negative port */
		printf("invalid port. \n");
		exit(0);
	}
	system("clear");
	printf("scanning: %s.\n", ipaddr);
	printf("low port: %d\n", lowport);
	printf("high port: %d\n\n", highport);
	printf("open ports:");

	reseed();

	for (x = lowport; x <= highport; x++) {

		fflush(stdout);

		sockdesc = socket(AF_INET, SOCK_STREAM, 0);

		if (sockdesc < 0) {
			perror("socket");
			exit(-1);
		}

		sin.sin_family = AF_INET;
		sin.sin_port = htons(x);
		sin.sin_addr.s_addr = resolvedhost;
		if (connect(sockdesc, (struct sockaddr *)&sin, sizeof(sin)) ==
		    0)
			printf(" %d", x);
		fflush(stdout);
		close(sockdesc);
	}
	printf("\n");
	exit(0);
}

void reseed(void)
{
	srand(time(NULL));
}

unsigned int resolve(char *host)
{
	/* resolve routine */

	struct hostent *he;
	struct sockaddr_in tmp;

	/* host lookup */
	he = gethostbyname(host);

	if (he) {
		/* temporary host copy */
		memcpy((caddr_t) & tmp.sin_addr.s_addr, he->h_addr,
		       he->h_length);
	} else {
		perror("resolving");
		exit(-1);
	}

	/* byte order return address */
	return (tmp.sin_addr.s_addr);
}

