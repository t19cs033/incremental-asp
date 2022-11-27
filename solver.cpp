#include <iostream>
#include <fstream>
#include <ext/stdio_filebuf.h>
#include <cstdlib>
#include <chrono>
#include <regex>
#include <stdio.h>
#include <unistd.h>
using namespace std;

int main(int argc, char *argv[])
{
	//ハード制約なし 64スレッド
	//string cmd = "clingo nsp-prepro.lp no-hard-opt-rules.lp SATfacts.lp --stats -t 64";
	//最適制約 64スレッド
	//string cmd = "clingo nsp-prepro.lp opt-rules.lp SATfacts.lp --stats -t 64";
	//ハード制約なし 8スレッド
	//string cmd = "clingo nsp-prepro.lp no-hard-opt-rules.lp SATfacts.lp --stats -t 8";
	//最適制約 8スレッド
	//string cmd = "clingo nsp-prepro.lp opt-rules.lp SATfacts.lp --stats -t 8";
	//ハード制約なし 4スレッド
	//string cmd = "clingo nsp-prepro.lp no-hard-opt-rules.lp SATfacts.lp --stats -t 4";
	//最適制約 4スレッド
	//string cmd = "clingo nsp-prepro.lp opt-rules.lp SATfacts.lp --stats -t 4";
	//ハード制約なし 2スレッド
	//string cmd = "clingo nsp-prepro.lp no-hard-opt-rules.lp SATfacts.lp --stats -t 2";
	//最適制約 2スレッド
	//string cmd = "clingo nsp-prepro.lp opt-rules.lp SATfacts.lp --stats -t 2";
	//ハード制約なし 1スレッド
	//string cmd = "clingo nsp-prepro.lp no-hard-opt-rules.lp SATfacts.lp --stats -t 1";
	//最適制約 1スレッド
	//string cmd = "clingo nsp-prepro.lp opt-rules.lp SATfacts.lp --stats -t 1";
/*	
	int i, opt;

    opterr = 0; //getopt()のエラーメッセージを無効にする。

    while ((opt = getopt(argc, argv, "tgh:")) != -1) {
        //コマンドライン引数のオプションがなくなるまで繰り返す
        switch (opt) {
            case 't':
                printf("-fがオプションとして渡されました\n");
                break;

            case 'g':
                printf("-gがオプションとして渡されました\n");
                break;

            case 'h':
                printf("-hがオプションとして渡されました\n");
                printf("引数optarg = %s\n", optarg);
                break;

            default: //'?' 
                //指定していないオプションが渡された場合
                printf("Usage: %s [-t] [-g] [-h argment] arg1 ...\n", argv[0]);
                break;
        }
    }

    //オプション以外の引数を出力する
    for (i = optind; i < argc; i++) {
        printf("arg = %s\n", argv[i]);
    }

*/
	// popenでコマンド実行後の出力をファイルポインタで受け取る
	FILE *fp = popen(cmd.c_str(), "r");


    ofstream fout( "solving-result.csv" ); // ファイルのオープン
    if( ! fout ){ // ファイルに問題がある場合
    cout << "ファイルをオープンできませんでした。\n";
    return 1; // 異常終了時の戻り値
    }

	// streambufを作成し，istreamのコンストラクタに渡す
	__gnu_cxx::stdio_filebuf<char> *p_fb = new __gnu_cxx::stdio_filebuf<char>(fp, ios_base::in);
	istream input(static_cast<std::streambuf *>(p_fb));

	chrono::system_clock::time_point  start, end, elaspse_find_time;

	// getlineでストリームからコマンド出力を受け取りファイルへ書き込む
	string buffer;
	bool stats_flag = false;

	while(getline(input, buffer)){
		
		if(!buffer.find("error")){
        	fout<<buffer<<endl;
			cout<<buffer<<endl;
		}

		if(!buffer.find("Solving")){
			start = chrono::system_clock::now();
			cout<<buffer<<endl;
			//fout<<"------------------------------「演算結果」------------------------------"<<endl;
			cout<<"------------------------------「演算結果」------------------------------"<<endl;
			//fout<<"Answer,Time(msec),Optimization(←high priority)"<<endl;
			cout<<"          | 経過時間(ミリ秒)| ペナルティ(プライオリティ順)"<<endl;
			//fout<<"----------------------------------------------------------------------"<<endl;
			//cout<<"----------------------------------------------------------------------"<<endl;
		}
        else if(!buffer.find("Answer")){
			elaspse_find_time = chrono::system_clock::now();
			auto elaspse_time = elaspse_find_time - start;
			auto msec_elaspse_time = std::chrono::duration_cast<chrono::milliseconds>(elaspse_time).count();
        	//fout<<buffer.substr(7)<<",";
			cout<<buffer<<" ";
			//fout<<"| time: ";
			cout<<"| time: ";
    		fout << msec_elaspse_time<<",";
			cout << msec_elaspse_time<<" ";
			//fout<<"msec |";
			cout<<"msec |";
		}
		else if(!buffer.find("Optimization:")){
			string opt = regex_replace(buffer.substr(14), regex(" "), ",");
        	//fout<<","<<buffer.substr(14)<<endl;
			cout<<" "<<buffer<<endl;
			fout<<opt<<endl;
		}
		else if(!buffer.find("OPTIMUM FOUND")){
			end = chrono::system_clock::now();
			cout<<buffer<<endl;
		}
		else if(!buffer.find("SATISFIABLE")){
        	fout<<buffer<<endl;
			cout<<buffer<<endl;
		}
		else if(!buffer.find("UNSATISFIABLE")){
        	fout<<buffer<<endl;
			cout<<buffer<<endl;
		}
		else if(!buffer.find("Models")){
			//fout<<"------------------------------「統計情報」------------------------------"<<endl;
			cout<<"------------------------------「統計情報」------------------------------"<<endl;
			//fout<<buffer<<endl;
			cout<<buffer<<endl;
			stats_flag = true;
		}
		else if(stats_flag){
			//fout<<buffer<<endl;
			cout<<buffer<<endl;
		}
	}
 
    // 処理に要した時間
    auto time = end - start;
 
    // 処理を開始した時間（タイムスタンプ）
	time_t date_time_stamp;
    date_time_stamp = chrono::system_clock::to_time_t(start);
    cout <<endl;
	//fout <<endl;
	cout << "実行日時: ";
	//fout << "実行日時: ";
	//fout << ctime(&date_time_stamp);
	cout << ctime(&date_time_stamp);
 
    // 処理に要した時間をミリ秒に変換
	cout << "実行時間: ";
	//fout << "実行時間: ";
    auto msec = std::chrono::duration_cast<chrono::milliseconds>(time).count();
	//fout << msec << " msec" << endl;
	cout << msec << " msec" << endl;

    fout.close();

	// 最後に解放
	delete p_fb;
	pclose(fp);

	return 0;
}

