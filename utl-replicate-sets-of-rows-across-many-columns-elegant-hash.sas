Replicate sets of rows across many columns=elegant hash

Repeat the first 5 famid x pid combination for each subsequent famid x pid combinations
(see RULES below)

Very elegant HASH solution.
The solution below works with arbitrary variable banes, even though I used z1-z400.
The hash processed 400 variables and 1,000,000 observations in less than 10 seconds

see SAS Forum
https://tinyurl.com/yblq3duj
https://communities.sas.com/t5/New-SAS-User/Replicate-multiple-results-across-rows/m-p/510985

slightly simplified Kurt Bremser solution
https://communities.sas.com/t5/user/viewprofilepage/user-id/11562


INPUT (Sample data for documentation only)
=====

WORK.HAVE total obs=30        |  RULES
                              |
 FAMID    PID    REC     Z    |  WANT
                              |
   1       1      1     111   |  111  Repeat these 5 for each
   1       1      2     112   |  112  subsequent set of 5 damid x oid
   1       1      3     113   |  113
   1       1      4     114   |  114
   1       1      5     115   |  115
                              |
   1       2      1     781   |  111  Replace
   1       2      2     235   |  112
   1       2      3     389   |  113
   1       2      4     476   |  114
   1       2      5     579   |  115
                              |
   1       3      1       .   |  111  Fill in
   1       3      2       .   |  112
   1       3      3       .   |  113
   1       3      4       .   |  114
   1       3      5       .   |  115

   2       1      1     552   |  552
   2       1      2     554   |  554
   2       1      3     556   |  556
   2       1      4     558   |  558
   2       1      5     559   |  559
                              |
   2       2      1       .   |  552  Fillin
   2       2      2       .   |  554
   2       2      3       .   |  556
   2       2      4       .   |  558
   2       2      5       .   |  559

   2       3      1     335   |  335
   2       3      2     334   |  334
   2       3      3     333   |  333
   2       3      4     332   |  332
   2       3      5     331   |  331


EXAMPLE OUTPUT 1,000,000 and 400 veriables (tiny dataset)
---------------------------------------------------------

Actual data (variable names do not have to be z1-z400 can be anything)

WORK.HAVE total obs=1,000,000

  FAMID PIDSAV REC Z1 Z2 Z3 Z4 Z5 Z6 Z7 Z8 Z9 Z10  ... Z400

    1      1    1  18 97 39 25 92 96 54 53  4   6       81
    1      1    2  12 44  0 42 79 15  8 49 65   2       12
    1      1    3  95 31 71 54 96 70 68 81 95  86        1
    1      1    4  96 40 36 95 33 66  1 69 77  13       50
    1      1    5  12 55  4 16 50 80 68 15 60  28       86

    1      2    1  18 97 39 25 92 96 54 53  4   6       81  repeated for next famid x pidsav
    1      2    2  12 44  0 42 79 15  8 49 65   2       12
    1      2    3  95 31 71 54 96 70 68 81 95  86        1
    1      2    4  96 40 36 95 33 66  1 69 77  13       50
    1      2    5  12 55  4 16 50 80 68 15 60  28       86

    1      3    1  18 97 39 25 92 96 54 53  4   6       81  repeated for next famid x pidsav
    1      3    2  12 44  0 42 79 15  8 49 65   2       12
    1      3    3  95 31 71 54 96 70 68 81 95  86        1
    1      3    4  96 40 36 95 33 66  1 69 77  13       50
    1      3    5  12 55  4 16 50 80 68 15 60  28       86

    1      4    1  18 97 39 25 92 96 54 53  4   6       81  repeated for next famid x pidsav
    1      4    2  12 44  0 42 79 15  8 49 65   2       12
    1      4    3  95 31 71 54 96 70 68 81 95  86        1
    1      4    4  96 40 36 95 33 66  1 69 77  13       50
    1      4    5  12 55  4 16 50 80 68 15 60  28       86

    2      1    1  21 82 41 39  2  5 18 58 24  82        4  New famid
    2      1    2  60 16 73 85 80 24 75 40 41  98       11
    2      1    3  57 37 49 91 36 15 57 11 81  58       98
    2      1    4  45 80 53 25 85 75 77 86 47  84       13
    2      1    5  65 80 57 42 43 68 56 37 79  73       33

    2      2    1  21 82 41 39  2  5 18 58 24  82        4  repeated for next famid x pidsav
    2      2    2  60 16 73 85 80 24 75 40 41  98       11
    2      2    3  57 37 49 91 36 15 57 11 81  58       98
    2      2    4  45 80 53 25 85 75 77 86 47  84       13
    2      2    5  65 80 57 42 43 68 56 37 79  73       33

    2      3    1  21 82 41 39  2  5 18 58 24  82        4  repeated for next famid x pidsav
    2      3    2  60 16 73 85 80 24 75 40 41  98       11
    2      3    3  57 37 49 91 36 15 57 11 81  58       98
    2      3    4  45 80 53 25 85 75 77 86 47  84       13
    2      3    5  65 80 57 42 43 68 56 37 79  73       33


PROCESS
=======

data want(drop=rc pid);

   retain famid pidsav  rec;

   /* load first five of each set of famids pid=1 */
   if _N_=1 then do;
      declare hash h(dataset:'have(where=(pid=1))');
      h.definekey('famid', 'rec');
      h.definedata(all:'yes');
      h.definedone();
   end;

   set have;
   pidsav=pid;
   /* if pid ne 1 repeat the hash finds - get 5 */
   if pid ne 1 then rc=h.find();

run;quit;

OUTPUT

see above

*                _              _       _
 _ __ ___   __ _| | _____    __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \  / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/ | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|  \__,_|\__,_|\__\__,_|

;

data have;
  retain famid pid 0 rec ;
  array forHun[*] z1-z400;
  do obs=1 to 100000;
     if mod(obs-1,2) = 0 then famid=famid+1;
     do rec=1 to 5;
        if rec=1 then pid=pid+1;
        do vx=1 to 400;
           forHun[vx]=int(100*uniform(obs));
        end;
       if famid ne lag(famid) then pid=1;
       output;
     end;
     do rec=1 to 5;
        if rec=1 then pid=pid+1;
        do vy=1 to 400;
           forHun[vy]=.;
        end;
        output;
     end;
  end;
  keep famid pid rec z:;
  stop;
run;quit;



