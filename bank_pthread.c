#include <stdlib.h>
#include <pthread.h>
#include <stdio.h>
#include <time.h>
#include <unistd.h>
#define NUM 10

pthread_mutex_t mymutex = PTHREAD_MUTEX_INITIALIZER;
int acnt_no[NUM];
int account[NUM];
int cnt;
int TotalMoney();
void *ThreadProc(void *arg);

int main()
{
	pthread_t account_t[NUM];
	void *temp;
	pthread_mutex_init(&mymutex, NULL);
	int i;
	for (i = 0; i < NUM; i++)
	{
		account[i] = 10000;
		acnt_no[i] = i;
	}
	cnt = 0;
	printf("Begin to transfer:\n");
	for (i = 0; i < NUM; i++)
	{
		printf("%d\n", i);
		if (pthread_create(&account_t[i], NULL, ThreadProc, (void *)&acnt_no[i])) //input args3 should be arraynums
		{
			printf("ERROR CREATING THREAD");
			abort();
		}
	}
	for (i = 0; i < NUM; i++)
	{
		pthread_join(account_t[i], &temp);
	}
	return 0;
}

int TotalMoney()
{
	int sum = 0;
	int i;
	for (i = 0; i < 10; i++)
	{
		printf("%d->>%d;", i, account[i]);
		sum = sum + account[i];
	}
	return sum;
}

void transfer(int from, int to, int money)
{

	while (account[from] < money)
		return;

	//pthread_mutex_lock(&mymutex);
	int x = account[from];
	x = x - money;
	//usleep(100);
	account[from] = x;
	account[to] = account[to] + money;
	cnt++;
	//error=============
	if (cnt % 10 == 0)
		printf("\nTotalMoney=%d\n", TotalMoney());
	//pthread_mutex_unlock(&mymutex);
	return;
}

void *ThreadProc(void *arg)
{
	int *ps = (int *)arg;
	int s = *ps;
	while (1)
	{
		srand((unsigned)time(NULL));
		int t = (int)(NUM * (rand() / (RAND_MAX + 1.0)));
		if (t == NUM)
			t = 0;
		if (t == s)
			t = (t + 1) % NUM;
		srand((unsigned)time(NULL));
		int money = 1 + (int)((10000 * (rand() / (RAND_MAX + 1.0))) / 4);
		transfer(s, t, money);
		//sleep(1);
	}
	pthread_exit(0);
}
