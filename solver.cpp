#include <iostream>
#include <fstream>
#include <ext/stdio_filebuf.h>
#include <cstdlib>
#include <chrono>
using namespace std;

int main()
{
	// なにか実行したいコマンド
	string cmd = "clingo nsp-prepro.lp opt-rules.lp facts.lp -t 64 --stats";

	// popenでコマンド実行後の出力をファイルポインタで受け取る
	FILE *fp = popen(cmd.c_str(), "r");


    ofstream fout( "solving-result.txt" ); // ファイルのオープン
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

	while(getline(input, buffer)){
		
		if(!buffer.find("Solving")){
			start = chrono::system_clock::now();
			cout<<buffer<<endl;
		}
        else if(!buffer.find("Answer")){
			elaspse_find_time = chrono::system_clock::now();
			auto elaspse_time = elaspse_find_time - start;
			auto msec_elaspse_time = std::chrono::duration_cast<chrono::milliseconds>(elaspse_time).count();
        	fout<<buffer<<endl;
			cout<<buffer<<endl;
			fout<<"time: ";
			cout<<"time: ";
    		fout << msec_elaspse_time;
			cout << msec_elaspse_time;
			fout<<" msec"<<endl;
			cout<<" msec"<<endl;
		}
		else if(!buffer.find("Optimization:")){
        	fout<<buffer<<endl;
			cout<<buffer<<endl;
		}
		else if(!buffer.find("OPTIMUM FOUND")){
			end = chrono::system_clock::now();
			cout<<buffer<<endl;
		}
		else if(!buffer.find("Models")){
			fout<<"--------------------「統計」--------------------"<<endl;
			cout<<"--------------------「統計」--------------------"<<endl;
			fout<<buffer<<endl;
			cout<<buffer<<endl;
		}
		else if(!buffer.find("OPTIMUM FOUND")){
			fout<<buffer<<endl;
			cout<<buffer<<endl;
		}

	}
 
    // 処理に要した時間
    auto time = end - start;
 
    // 処理を開始した時間（タイムスタンプ）
	time_t date_time_stamp;
    date_time_stamp = chrono::system_clock::to_time_t(start);
    cout <<endl;
	fout <<endl;
	cout << "実行日時: ";
	fout << "実行日時: ";
	fout << ctime(&date_time_stamp);
	cout << ctime(&date_time_stamp);
 
    // 処理に要した時間をミリ秒に変換
	cout << "実行時間: ";
	fout << "実行時間: ";
    auto msec = std::chrono::duration_cast<chrono::milliseconds>(time).count();
	fout << msec << " msec" << endl;
	cout << msec << " msec" << endl;

    fout.close();

	// 最後に解放
	delete p_fb;
	pclose(fp);

	return 0;
}

