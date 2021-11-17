/*************************************************************************
	> File Name: writer_reader.c
	> Author:jiangze 
	> Mail: 
	> Created Time: 2021年11月17日 星期三 18时47分21秒
 ************************************************************************/

#include<stdio.h>
#include<stdlib.h>
#include<unistd.h>
#include<pthread.h>
#include<semaphore.h>
#define WRITER_MAX_NUM 10
#define READER_MAX_NUM 10

int count = 0; // reader count;
pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
sem_t wrt;
sem_t wt;
int filecontext = 10;// init filecontext 
void *writer(void * wno);
void *reader(void *rno);

int reader_no[READER_MAX_NUM];
int writer_no[WRITER_MAX_NUM];


int main(int argv,char **argc){
    pthread_t writer_t[WRITER_MAX_NUM];
    pthread_t reader_t[READER_MAX_NUM];
    pthread_mutex_init(&mutex,NULL);    
    sem_init(&wrt,0,1);
    sem_init(&wt,0,1);
    for(int i = 0 ; i < WRITER_MAX_NUM;i++){
        writer_no[i] = i;
    }
    for(int i = 0 ; i < READER_MAX_NUM;i++){
        reader_no[i] = i ;
    }

    for(int i = 0 ; i < WRITER_MAX_NUM;i++){ 
        if(pthread_create(&writer_t[i],NULL,(void *)writer,(void*)&writer_no[i])){
            printf("ERROR CREATING THREAD\n");
			abort();
        }
    }
    
    for(int i = 0 ; i < READER_MAX_NUM;i++){
        if(pthread_create(&reader_t[i],NULL,(void*)reader,(void*)&reader_no[i])){
            printf("ERROR CREATING THREAD\n");
            abort();
        }
    }
    for(int i  = 0 ; i < READER_MAX_NUM;i++){
        pthread_join(reader_t[i],NULL);
    }
    for(int i = 0 ; i < WRITER_MAX_NUM ; i++){
        pthread_join(writer_t[i],NULL);
    }

    pthread_mutex_destroy(&mutex);
    sem_destroy(&wrt);
    sem_destroy(&wt);
    return 0;
}

void *writer(void * wno){
        sem_wait(&wt);
        sem_wait(&wrt);
        //Writer  writing  file
        //usleep(10);
        filecontext*=2;
        printf("Writer %d modify filecontext: %d \n",(*(int*)wno),filecontext);
        sem_post(&wrt);
        sem_post(&wt);
}

void *reader(void *rno){
        sem_wait(&wt);
        pthread_mutex_lock(&mutex);
        if(count==0)
            sem_wait(&wrt);
        count++;
        pthread_mutex_unlock(&mutex);
        sem_post(&wt);
        //reader read file
        usleep(100);
        printf("Reader %d read filecontext : %d\n",*((int*)rno),filecontext);
        pthread_mutex_lock(&mutex);
        count--;
        if(count == 0 ){
            sem_post(&wrt);
        }
        pthread_mutex_unlock(&mutex);

}
