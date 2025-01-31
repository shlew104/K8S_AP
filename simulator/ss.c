#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>  // For gettimeofday
#include <pthread.h>
#include <goldilocks.h>

#define DSN_NAME "GOLDILOCKS"
#define DB_USER "ss"
#define DB_PASS "ss"

// 작업 종류에 따른 쿼리 정의
//#define SELECT_QUERY "SELECT * FROM T_TEST P LEFT OUTER JOIN T_TEST S ON P.MDN=S.MDN WHERE P.MDN=?;"
#define SELECT_QUERY "SELECT * FROM T_TEST WHERE P.MDN=?;"
#define INSERT_QUERY "INSERT INTO T_TEST (MDN, MSISDN, MVNO, OCS, CREATE_TIME, UE_OS_VER, PRODUCT_ID) VALUES (?, ?, ?, 'S', TO_CHAR(SYSDATE, 'YYYYMMDDhh24miss'), ?, ?);"
#define UPDATE_QUERY "UPDATE T_TEST SET MVNO=?, UPDATE_TIME=TO_CHAR(SYSDATE, 'YYYYMMDDhh24miss'), UE_OS_VER=?, PRODUCT_ID=? WHERE MDN=?;"
#define DELETE_QUERY "DELETE FROM T_TEST WHERE MDN=?;"

// 스레드 정보 구조체
typedef struct {
    int thread_id;
    int rows;
    char operation;
} ThreadData;

// 에러 메시지 출력 함수
void print_error(SQLSMALLINT handleType, SQLHANDLE handle) {
    SQLCHAR sqlState[6], message[SQL_MAX_MESSAGE_LENGTH];
    SQLINTEGER nativeError;
    SQLSMALLINT textLength;
    SQLRETURN ret;

    int i = 1;
    while ((ret = SQLGetDiagRec(handleType, handle, i, sqlState, &nativeError, message, sizeof(message), &textLength)) != SQL_NO_DATA) {
        printf("ODBC Error: SQLSTATE=%s, NativeError=%d, Message=%s\n", sqlState, nativeError, message);
        i++;
    }
}

// 현재 시간을 yyyy-mm-dd hh:mm:ss.millisecond 형식으로 변환하여 문자열로 반환하는 함수
void get_current_time(char *buffer, size_t size) {
    struct timeval tv;
    gettimeofday(&tv, NULL);
    struct tm *timeinfo = localtime(&tv.tv_sec);
    
    snprintf(buffer, size, "%04d-%02d-%02d %02d:%02d:%02d.%03ld",
             timeinfo->tm_year + 1900, timeinfo->tm_mon + 1, timeinfo->tm_mday,
             timeinfo->tm_hour, timeinfo->tm_min, timeinfo->tm_sec, tv.tv_usec / 1000);
}

// 데이터베이스 연결 함수
int db_connect(SQLHENV *hEnv, SQLHDBC *hDbc) {
    SQLAllocHandle(SQL_HANDLE_ENV, SQL_NULL_HANDLE, hEnv);
    SQLSetEnvAttr(*hEnv, SQL_ATTR_ODBC_VERSION, (void*) SQL_OV_ODBC3, 0);
    SQLAllocHandle(SQL_HANDLE_DBC, *hEnv, hDbc);

    SQLCHAR retconstring[1024];
    SQLRETURN ret = SQLDriverConnect(*hDbc, NULL, (SQLCHAR*) "DSN=" DSN_NAME ";UID=" DB_USER ";PWD=" DB_PASS ";", SQL_NTS, retconstring, 1024, NULL, SQL_DRIVER_COMPLETE);
    if (ret != SQL_SUCCESS && ret != SQL_SUCCESS_WITH_INFO) {
        print_error(SQL_HANDLE_DBC, *hDbc);
        return SQL_ERROR;
    }
    
    SQLSetConnectAttr(*hDbc, SQL_ATTR_AUTOCOMMIT, (SQLPOINTER) SQL_AUTOCOMMIT_OFF, SQL_IS_UINTEGER);
    return SQL_SUCCESS;
}

// 데이터베이스 연결 해제 함수
void db_disconnect(SQLHENV hEnv, SQLHDBC hDbc) {
    SQLDisconnect(hDbc);
    SQLFreeHandle(SQL_HANDLE_DBC, hDbc);
    SQLFreeHandle(SQL_HANDLE_ENV, hEnv);
}

// SQL 실행 함수
void *execute_sql(void *arg) {
    ThreadData *data = (ThreadData*) arg;
    SQLHENV hEnv;
    SQLHDBC hDbc;
    SQLHSTMT hStmt;
    
    // 각 스레드마다 독립적인 DB 연결 생성
    if (db_connect(&hEnv, &hDbc) != SQL_SUCCESS) {
        return NULL; // 연결 실패 시 종료
    }
    
    SQLAllocHandle(SQL_HANDLE_STMT, hDbc, &hStmt);
    SQLRETURN ret;

    char start_time_str[30], end_time_str[30];
    get_current_time(start_time_str, sizeof(start_time_str));

    struct timeval start_time, end_time;
    gettimeofday(&start_time, NULL);

    const char *query;
    
    // 쿼리 선택
    switch (data->operation) {
        case 's': query = SELECT_QUERY; break;
        case 'i': query = INSERT_QUERY; break;
        case 'u': query = UPDATE_QUERY; break;
        case 'd': query = DELETE_QUERY; break;
        default:
            fprintf(stderr, "Unknown operation: %c\n", data->operation);
            db_disconnect(hEnv, hDbc); // 연결 해제
            return NULL;
    }

    // 쿼리 준비
    SQLPrepare(hStmt, (SQLCHAR*) query, SQL_NTS);

    for (int i = 0; i < data->rows; i++) {
        // 고유한 mdn 값 생성
        char mdn[16];
        snprintf(mdn, sizeof(mdn), "010%03d%04d", data->thread_id, i);
        
        char msisdn[12] = "MSISDN";
        char mvno[5] = "MVNO"; // Length adjusted to varchar(4)
        char ue_os_ver[10] = "VER1";
        char product_id[32] = "PROD123456789";

        // 바인드 파라미터 설정
        SQLBindParameter(hStmt, 1, SQL_PARAM_INPUT, SQL_C_CHAR, SQL_CHAR, 0, 0, mdn, 0, NULL);
        
        if (data->operation == 'i') {
            SQLBindParameter(hStmt, 2, SQL_PARAM_INPUT, SQL_C_CHAR, SQL_CHAR, 0, 0, msisdn, 0, NULL);
            SQLBindParameter(hStmt, 3, SQL_PARAM_INPUT, SQL_C_CHAR, SQL_CHAR, 0, 0, mvno, 0, NULL);
            SQLBindParameter(hStmt, 4, SQL_PARAM_INPUT, SQL_C_CHAR, SQL_CHAR, 0, 0, ue_os_ver, 0, NULL);
            SQLBindParameter(hStmt, 5, SQL_PARAM_INPUT, SQL_C_CHAR, SQL_CHAR, 0, 0, product_id, 0, NULL);
        } else if (data->operation == 'u') {
            SQLBindParameter(hStmt, 1, SQL_PARAM_INPUT, SQL_C_CHAR, SQL_CHAR, 0, 0, mvno, 0, NULL);
            SQLBindParameter(hStmt, 2, SQL_PARAM_INPUT, SQL_C_CHAR, SQL_CHAR, 0, 0, ue_os_ver, 0, NULL);
            SQLBindParameter(hStmt, 3, SQL_PARAM_INPUT, SQL_C_CHAR, SQL_CHAR, 0, 0, product_id, 0, NULL);
            SQLBindParameter(hStmt, 4, SQL_PARAM_INPUT, SQL_C_CHAR, SQL_CHAR, 0, 0, mdn, 0, NULL);
        }

        ret = SQLExecute(hStmt);
        if (ret != SQL_SUCCESS && ret != SQL_SUCCESS_WITH_INFO) {
            printf("Thread %d: SQL execution failed\n", data->thread_id);
            print_error(SQL_HANDLE_STMT, hStmt);
            SQLTransact(hEnv, hDbc, SQL_ROLLBACK);
            break;
        }

        if (data->operation == 's') {
            while ((ret = SQLFetch(hStmt)) != SQL_NO_DATA) {
                if (ret == SQL_ERROR) {
                    printf("Thread %d: Error fetching SELECT results\n", data->thread_id);
                    print_error(SQL_HANDLE_STMT, hStmt);
                    break;
                }
            }
            SQLCloseCursor(hStmt); // Cursor 종료로 cursor state 에러 방지
        }
        
        if( i % 100 == 0 ) {
            SQLTransact(hEnv, hDbc, SQL_COMMIT); 
        }
        //SQLTransact(data->hEnv, data->hDbc, SQL_COMMIT);
    }

    SQLTransact(hEnv, hDbc, SQL_COMMIT);

    gettimeofday(&end_time, NULL);
    get_current_time(end_time_str, sizeof(end_time_str));
    double time_spent = (end_time.tv_sec - start_time.tv_sec) * 1000.0; // 초를 밀리초로 변환
    time_spent += (end_time.tv_usec - start_time.tv_usec) / 1000.0; // 추가로 마이크로초를 밀리초로 변환

    double tps = data->rows / (time_spent / 1000.0); // TPS 계산

    printf("Thread %d start at [%s], end at [%s], duration: [%.2f ms], TPS: [%.2f]\n", data->thread_id, start_time_str, end_time_str, time_spent, tps);
    
    SQLFreeHandle(SQL_HANDLE_STMT, hStmt);
    db_disconnect(hEnv, hDbc); // 스레드 종료 시 연결 해제
    return NULL;
}

int main(int argc, char *argv[]) {
    if (argc != 4) {
        fprintf(stderr, "Usage: %s <num_threads> <operation (s/i/u/d)> <rows_per_thread>\n", argv[0]);
        return 1;
    }

    int num_threads = atoi(argv[1]);
    char operation = argv[2][0];
    int rows_per_thread = atoi(argv[3]);

    pthread_t threads[num_threads];
    ThreadData thread_data[num_threads];

    for (int i = 0; i < num_threads; i++) {
        thread_data[i].thread_id = i;
        thread_data[i].rows = rows_per_thread;
        thread_data[i].operation = operation;

        pthread_create(&threads[i], NULL, execute_sql, &thread_data[i]);
    }

    for (int i = 0; i < num_threads; i++) {
        pthread_join(threads[i], NULL);
    }

    return 0;
}

