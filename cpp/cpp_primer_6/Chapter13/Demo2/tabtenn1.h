// tabtenn1.h -- a table-tennis base class
// ����TableTennisPlayer��Name()��HasTable()������������RatedPlayer��
// Rating()��������Ϊ���const��Ա��������Ϊ���ǲ����޸ĵ��ö���
#ifndef TABTENN1_H_
#define TABTENN1_H_
#include <string>
using std::string;
// simple base class
class TableTennisPlayer
{
private:
    string firstname;
    string lastname;
    bool hasTable;
public:
    TableTennisPlayer (const string & fn = "none",
                       const string & ln = "none", bool ht = false);
    void Name() const;//const���ں���Name()���棬�����������޸ĵ��ö���
    bool HasTable() const { return hasTable; };//ͬ�ϣ�HasTable�������޸ĵ��ö���
    void ResetTable(bool v) { hasTable = v; };
};

// simple derived class ������RatedPlayer�����м̳�TableTennisPlayer��
class RatedPlayer : public TableTennisPlayer
{
private:
    unsigned int rating;
public:
    RatedPlayer (unsigned int r = 0, const string & fn = "none",
                 const string & ln = "none", bool ht = false);
    RatedPlayer(unsigned int r, const TableTennisPlayer & tp);
    unsigned int Rating() const { return rating; }
    void ResetRating (unsigned int r) {rating = r;}
};

#endif
