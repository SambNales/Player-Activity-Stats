enum CACHE_LINES
{
    CL_CACHETIME = 0,
    CL_FULLTIME,
    CL_FULLTIME_SERVER,
    CL_CONNECTS,
    CL_CONNECTS_SERVER,
    CL_FIRSTCON,
    CL_FIRSTCON_SERVER
};

#define C_PATH "data/GAstat/%s.dat"

enum struct Cache
{
    File hFile;
    char szPath[PMP];
    bool createdNow;

    void Build(const char[] szSteam)
    {
        BuildPath(Path_SM, this.szPath, PMP, C_PATH, szSteam);
    }

    void Open(const char[] szFlags)
    {
        this.hFile = OpenFile(this.szPath, szFlags);
    }

    bool IsCachingExists()
    {
        return FileExists(this.szPath);
    }

    void CreateCache()
    {
        this.createdNow = true;
        OpenFile(this.szPath, "w+").Close();
    }

    bool IsCacheEmpty()
    {
        return FileSize(this.szPath) < 1;
    }

    bool CacheOutdated()
    {
        char data[16];

        if(this.IsCacheEmpty() || this.createdNow)
            return true;

        if(!this.hFile)
            this.Open("r");
        
        this.hFile.ReadLine(SZ(data));
        this.hFile.Seek(0, SEEK_SET);
        
        return GetTime() - StringToInt(data) >= iCacheTime*60;
    }

    void LoadFromCache(int iClient)
    {
        int pos;
        char szBuf[16];

        if(!this.hFile)
            this.Open("r");
        
        while(!this.hFile.EndOfFile() && this.hFile.ReadLine(SZ(szBuf)))
        {
            if(pos)
            {
                //LogMessage("DATA: %s | %N", szBuf, iClient);
                switch(pos)
                {
                    case CL_FULLTIME: Stat[eGlobal].iPlayTime[iClient] = StringToInt(szBuf);
                    case CL_FULLTIME_SERVER: Stat[eServer].iPlayTime[iClient] = StringToInt(szBuf);
                    case CL_CONNECTS: Stat[eGlobal].iPlayerCon[iClient] = StringToInt(szBuf);
                    case CL_CONNECTS_SERVER: Stat[eServer].iPlayerCon[iClient] = StringToInt(szBuf);
                    case CL_FIRSTCON: Stat[eGlobal].iPlayerFirst[iClient] = StringToInt(szBuf);
                    case CL_FIRSTCON_SERVER: Stat[eServer].iPlayerFirst[iClient] = StringToInt(szBuf);
                }
            }

            pos++;
        }

        this.hFile.Seek(0, SEEK_SET);
    }

    void WriteToCache(int iClient)
    {
        this.hFile.WriteLine("%i", GetTime());
        this.hFile.WriteLine("%i", Stat[eGlobal].iPlayTime[iClient]);
        this.hFile.WriteLine("%i", Stat[eServer].iPlayTime[iClient]);
        this.hFile.WriteLine("%i", Stat[eGlobal].iPlayerCon[iClient]);
        this.hFile.WriteLine("%i", Stat[eServer].iPlayerCon[iClient]);
        this.hFile.WriteLine("%i", Stat[eGlobal].iPlayerFirst[iClient]);
        this.hFile.WriteLine("%i", Stat[eServer].iPlayerFirst[iClient]);

        this.hFile.Seek(0, SEEK_SET);
    }

    void Destroy()
    {
        this.createdNow = false;
        this.szPath[0] = 0;
        
        if(this.hFile)
            delete this.hFile;
    }
}