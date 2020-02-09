#include "skynet.h"

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <time.h>

//时间字符串长度+ .log长度
#define DAY_STR_LEN 15
#define SECONDS_ONE_DAY 86400

struct logger {
	FILE * handle;
	char * filename;
	char * origFn;
	int close;
	int mday;
	time_t today0hour;
};

struct logger *
logger_create(void) {
	struct logger * inst = skynet_malloc(sizeof(*inst));
	inst->handle = NULL;
	inst->close = 0;
	inst->filename = NULL;
	inst->origFn = NULL;
	inst->mday = 0;
	inst->today0hour = 0;

	return inst;
}

void
logger_release(struct logger * inst) {
	if (inst->close) {
		fclose(inst->handle);
	}
	skynet_free(inst->filename);
	skynet_free(inst->origFn);
	skynet_free(inst);
}

static int
logger_cb(struct skynet_context * context, void *ud, int type, int session, uint32_t source, const void * msg, size_t sz) {
	struct logger * inst = ud;
	time_t seconds = time(NULL);
	struct tm timenow;
	localtime_r(&seconds,&timenow);
	double dt = difftime(seconds,inst->today0hour);
	FILE * nhandle;
	switch (type) {
		case PTYPE_SYSTEM:
			if (inst->filename) {
				inst->handle = freopen(inst->filename, "a", inst->handle);
			}
			break;
		case PTYPE_RESPONSE:
			//TODO change filename
			break;
			/*case PTYPE_LUA:*/
			/*//TODO add delay*/
			/*break;*/
		case PTYPE_TEXT:
			if (dt > SECONDS_ONE_DAY ){
				char fn[256] = {0};
				sprintf(fn,"%s_%d-%02d-%02d.log",inst->origFn,(1900+timenow.tm_year),(timenow.tm_mon+1),timenow.tm_mday);
				nhandle = fopen(fn,"a");
				if (nhandle != NULL) {
					inst->today0hour += SECONDS_ONE_DAY;
					fclose(inst->handle);
					inst->handle = NULL;
					inst->handle = nhandle;
					strcpy(inst->filename,fn);
				}
			}
			if (inst->handle != NULL) {
				fprintf(inst->handle, "%02d:%02d:%02d",timenow.tm_hour,timenow.tm_min,timenow.tm_sec);
				fprintf(inst->handle, " [%x] ",source);
				fwrite(msg, sz , 1, inst->handle);
				fprintf(inst->handle, "\n");
				fflush(inst->handle);
			}
			break;
	}
	return 0;
}

int
logger_init(struct logger * inst, struct skynet_context *ctx, const char * parm) {
	if (parm) {
		inst->filename = skynet_malloc(strlen(parm)+1+DAY_STR_LEN);
		inst->origFn = skynet_malloc(strlen(parm)+1);
		strcpy(inst->origFn,parm);

		time_t seconds;
		seconds = time((time_t*)NULL);
		struct tm timenow;
		localtime_r(&seconds,&timenow);
		sprintf(inst->filename,"%s_%d-%02d-%02d.log",parm,(1900+timenow.tm_year),(timenow.tm_mon+1),timenow.tm_mday);
		timenow.tm_sec = 0;
		timenow.tm_hour = 0;
		timenow.tm_min = 0;
		inst->today0hour = mktime(&timenow);
		inst->close = 1;

		inst->handle = fopen(inst->filename,"a");
		if (inst->handle == NULL) {
			return 1;
		}

	} else {
		inst->handle = stdout;
	}
	if (inst->handle) {
		skynet_callback(ctx, inst, logger_cb);
		return 0;
	}
	return 1;
}
