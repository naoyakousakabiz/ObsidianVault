-- LifeOS P1-1 launchd wrapper (FDA対応用)
-- 目的: launchd直実行だとGoogle Drive配下がTCCで弾かれることがあるため、
--      Full Disk Access を付与できる .app から p1-1-collect.sh を起動する。

set shPath to "/Users/kousakanaoya/scripts/p1-1-collect.sh"

try
	do shell script "/bin/bash " & quoted form of shPath & " < /dev/null >/dev/null 2>&1"
on error errMsg number errNum
	-- ここはUIを出さず、失敗しても終了する（詳細はrun.logに残る）
end try

