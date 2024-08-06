%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int id=0;
struct timee timeadd(struct timee a,struct timee b);
struct timee timesub(struct timee a,struct timee b);
struct timee gettime(int a,int b,int c);
void printtime(struct timee a);
void savevariable(char a[50],struct timee b);
struct timee getvariable(char a[50]);
struct timee normal(struct timee a);
int bigger(struct timee a,struct timee b);
struct day dayadd(struct day a,int b);
struct day daysub(struct day a,int b);
struct day getday(int a,int b,int c);
int islegal(struct day a);
int isleapyear(int year);
void printday(struct day a);
%}
%union{
  int a;
  struct timee{
    char name[50];
    int h;
    int m;
    int s;
  }b;
  char c[50];
  struct day{
    int y;
    int m;
    int d;
  }d;
}
%token <a> NUMBER
%token <c> VARIABLE
%token ADD SUB ADD1 SUB1 MUL CONNECT CONNECT1 EQL LEFTQUA RIGHTQUA
%token EOL
%type <b> exp factor multiplevar
%type <d> exp1 factor1
%type <a> exp2
%left ADD SUB MUL CONNECT1
%%

calclist:/*註解*/
  |calclist exp EOL{printtime($2);}
  |calclist exp1 EOL{printday($2);}
  |calclist multiplevar EOL{printtime($2);}
  ;
multiplevar:VARIABLE EQL multiplevar{savevariable($1,$3);$$=$3;}
           |VARIABLE EQL exp{savevariable($1,$3);$$=$3;}
   ;
exp:exp ADD exp{$$=timeadd($1,$3);}
   |exp SUB exp{$$=timesub($1,$3);}
   |LEFTQUA exp RIGHTQUA{$$=$2;}
   |factor{$$=$1;}
   |VARIABLE{$$=getvariable($1);}
   ;
exp1:factor1 SUB1 exp2{$$=daysub($1,$3);}
    |factor1 ADD1 exp2{$$=dayadd($1,$3);}
    |factor1{$$=$1;}
   ;
exp2:exp2 ADD exp2{$$=$1+$3;}
    |exp2 SUB exp2{$$=$1-$3;}
    |exp2 MUL exp2{$$=$1*$3;}
    |exp2 CONNECT1 exp2{$$=$1/$3;}
    |NUMBER{$$=$1;}
    |LEFTQUA exp2 RIGHTQUA{$$=$2;}
   ;
factor:NUMBER CONNECT NUMBER CONNECT NUMBER{$$=gettime($1,$3,$5);}
   ;
factor1:NUMBER CONNECT1 NUMBER CONNECT1 NUMBER{$$=getday($1,$3,$5);}
   ;
%%
struct timee var[1000];
int main(int argc,char **argv){
	yyparse();
}

yyerror(char *s)
{
 fprintf(stderr,"error:%s\n",s);
}

struct timee normal(struct timee a){
  int c=0;
  c=a.s/60;
  a.s%=60;
  a.m+=c;
  c=a.m/60;
  a.m%=60;
  a.h+=c;
  return a;
}

int bigger(struct timee a,struct timee b){
  if(a.h>b.h) return 1;
  if(a.h<b.h) return 0;
  if(a.m>b.m) return 1;
  if(a.m<b.m) return 0;
  if(a.s>b.s) return 1;
  if(a.s<b.s) return 0;
  return 2;
}

void savevariable(char a[50],struct timee b){
  int i=0;
  b=normal(b);
  for(i=0;i<id;i++){
    if(strcmp(var[i].name,a)==0){
      var[i].h=b.h;
      var[i].m=b.m;
      var[i].s=b.s;
      break;
    }
  }
  if(i==id){
    strcpy(var[i].name,a);
    var[i].h=b.h;
    var[i].m=b.m;
    var[i].s=b.s;
    id++;
  }
}

struct timee getvariable(char a[50]){
  int i=0;
  for(i=0;i<id;i++){
    if(strcmp(var[i].name,a)==0){
      return var[i];
    }
  }
  if(i==id){
    exit(0);
  }
}

struct timee timeadd(struct timee a,struct timee b){
  struct timee tmp;
  int tmp1=0;
  tmp.s=(a.s+b.s)%60;
  tmp1=(a.s+b.s)/60;
  tmp.m=(a.m+b.m)%60+tmp1;
  tmp1=(a.m+b.m)/60;
  tmp.h=a.h+b.h+tmp1;
  return tmp;
}

struct timee timesub(struct timee a,struct timee b){
  struct timee tmp;
  a=normal(a);
  b=normal(b);
  if(!bigger(a,b)){
    struct timee tmp1;
    tmp1=a;
    a=b;
    b=tmp1;
  }
  int c=0;
  if(a.s-b.s>=0){
    tmp.s=a.s-b.s;
  }
  else{
    c=1;
    tmp.s=a.s-b.s+60;
  }
  if(a.m-b.m-c>=0){
    tmp.m=a.m-b.m-c;
    c=0;
  }
  else{
    tmp.m=a.m-b.m-c+60;
    c=1;
  }
  tmp.h=a.h-b.h-c;
  return tmp;
}

struct timee gettime(int a,int b,int c){
  struct timee tmp;
  tmp.s=c;
  tmp.m=b;
  tmp.h=a;
  return tmp;
}

void printtime(struct timee a){
  a=normal(a);
  printf("%d:%d:%d\n",a.h,a.m,a.s);
}

int isleapyear(int year){
  if(year%4 == 0)
    {
        if( year%100 == 0)
        {
            if ( year%400 == 0)
                return 1;
            else
                return 0;
        }
        else
            return 1;
    }
    else
        return 0;
}

int islegal(struct day a){
  int mapday[13]={0,31,28,31,30,31,30,31,31,30,31,30,31};
  if(isleapyear(a.y)){
    mapday[2]=29;
  }
  if(a.y<0) return 0;
  if(a.m<=0 || a.m>12) return 0;
  if(a.d<=0 || a.d>mapday[a.m]) return 0;
  return 1;
}

struct day dayadd(struct day a,int b){
  if(b<0){
    return daysub(a,-1*b);
  }
  if(!islegal(a)) exit(0);
  int c=0;
  if(!(a.m<2 || (a.m==2&&a.d!=29))) c=1;
  while(1){
    if(isleapyear(a.y+c)){
      if(b<366) break;
      else{
        b-=366;
        a.y+=1;
      }
    }
    else{
      if(b<365) break;
      else{
        b-=365;
        a.y+=1;
      }
    }
  }
  int mapday[13]={0,31,28,31,30,31,30,31,31,30,31,30,31};
  if(isleapyear(a.y)){
    mapday[2]=29;
  }
  if(b<=mapday[a.m]-a.d){
    a.d+=b;
    return a;
  }
  else{
    b-=(mapday[a.m]-a.d+1);
    a.d=1;
    a.m=a.m%12+1;
    if(a.m==1) a.y++;
    if(isleapyear(a.y)){
      mapday[2]=29;
    }
  }
  while(1){
    if(b<=0) break;
    if(b<mapday[a.m]){
      a.d+=b;
      break;
    }
    else{
      b-=mapday[a.m];
      a.m=a.m%12+1;
      if(a.m==1) a.y++;
      if(isleapyear(a.y)){
        mapday[2]=29;
      }
      else{
        mapday[2]=28;
      }
    }
  }
  return a;
}

struct day daysub(struct day a,int b){
  if(b<0){
    return dayadd(a,-1*b);
  }
  if(!islegal(a)) exit(0);
  int c=0;
  if(a.m<2 || (a.m==2&&a.d!=29)) c=1;
  while(1){
    if(isleapyear(a.y-c)){
      if(b<366) break;
      else{
        b-=366;
        a.y-=1;
      }
    }
    else{
      if(b<365) break;
      else{
        b-=365;
        a.y-=1;
      }
    }
  }
  int mapday[13]={0,31,28,31,30,31,30,31,31,30,31,30,31};
  if(isleapyear(a.y)){
    mapday[2]=29;
  }
  if(b<a.d){
    a.d-=b;
    return a;
  }
  else{
    b-=a.d;
    a.m=(a.m+10)%12+1;
    a.d=mapday[a.m];
    if(a.m==12) a.y--;
    if(isleapyear(a.y)){
      mapday[2]=29;
    }
  }
  while(1){
    if(b<=0) break;
    if(b<mapday[a.m]){
      a.d-=b;
      break;
    }
    else{
      b-=mapday[a.m];
      a.m=(a.m+10)%12+1;
      a.d=mapday[a.m];
      if(a.m==12) a.y--;
      if(isleapyear(a.y)){
        mapday[2]=29;
      }
      else{
        mapday[2]=28;
      }
    }
  }
  return a;
}


struct day getday(int a,int b,int c){
  struct day tmp;
  tmp.y=a;
  tmp.m=b;
  tmp.d=c;
  return tmp;
}

void printday(struct day a){
  printf("%d/%d/%d\n",a.y,a.m,a.d);
}
