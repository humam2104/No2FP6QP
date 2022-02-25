
class No2FP6QPMut extends KFMutator;

var byte QPCount;
var byte FPCount;
var byte MaxFPCount;
var byte MaxQPCount;

function bool IsTraderWave()
{
    if (MyKFGI.MyKFGRI.bTraderIsOpen)
    {
        return true;
    }
    else if (MyKFGI.MyKFGRI.bTraderIsOpen == false)
    {
        return false;
    }
}

function ModifyPlayer(Pawn P)
{
        SetTimer(20, true, nameof(ResetCounters));
}


function bool IsQPLimitExceeded()
{
    return (QPCount > MaxQPCount && FPCount < MaxFPCount && FPCount != 0 || 
    QPCount > 2 * MaxQPCount || FPCount == MaxFPCount);
}
function bool IsFPLimitExceeded()
{
    return (FPCount > MaxFPCount || QPCount >= MaxQPCount && FPCount > MaxFPCount - 1);
}

function ModifyAI(Pawn AIPawn)
{
    local KFPawn_ZedFleshpoundMini MiniFP;
    local KFPawn_ZedFleshpound ZedFP;
    local KFAIController_Monster KFAIC_M;
    if (KFPawn_ZedFleshpound(AIPawn) == none)
        return;
    if (KFPawn_ZedFleshpoundMini(AIPawn) != none)
    {
        QPCount++;
        KFPawn_ZedFleshpoundMini(AIPawn).SetEnraged(false);
    }
    else if (KFPawn_ZedFleshpound(AIPawn) != none)
    {
        FPCount++;
        KFPawn_ZedFleshpound(AIPawn).SetEnraged(false);
    }


    if (QPCount > MaxQPCount && FPCount >= MaxFPCount - 1 || FPCount > MaxFPCount - 1 ||
        QPCount > MaxQPCount * 2)
    {
        foreach WorldInfo.AllControllers( class'KFAIController_Monster', KFAIC_M)
        {
            MiniFP = KFPawn_ZedFleshpoundMini(KFAIC_M.MyKFPawn);
            ZedFP = KFPawn_ZedFleshpound(KFAIC_M.MyKFPawn);
            if ( MiniFP != none && IsQPLimitExceeded())
            {
                MiniFP.Destroy();
                QPCount--;
            }
            else if ( ZedFP != none && MiniFP == none && IsFPLimitExceeded())
            {
                ZedFP.Destroy();
                FPCount--;
            }
            else if (QPCount == MaxQPCount && FPCount < MaxFPCount
                    || FPCount == MaxFPCount - 1 && QPCount <= MaxQPCount
                    || FPCount == MaxFPCount && QPCount == 0)
            {
                break;
            }
        }
    }
}

function ScoreKill(Controller Killer, Controller Killed)
{
    local KFPawn_ZedFleshpoundMini MiniFP;
    local KFPawn_ZedFleshpound ZedFP;

    MiniFP = KFPawn_ZedFleshpoundMini(KFAIController(Killed).MyKFPawn);
    ZedFP = KFPawn_ZedFleshpound(KFAIController(Killed).MyKFPawn);
    if (MiniFP != none)
    {
        QPCount--;
    }
    else if (ZedFP != none)
    {
        FPCount--;
    }
}

function ResetCounters()
{
    if (IsTraderWave())
    {
        QPCount = 0;
        FPCount = 0;
    }

}

DefaultProperties
{
    QPCount = 0
    FPCount = 0
    MaxFPCount = 3
    MaxQPCount = 3
}

