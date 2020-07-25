-- body tag

FISH_TAG = 1;
THIS_BULLET_TAG = 2;
OTHER_BULLET_TAG = 3;

_freshRateArray = {
    100,--// FISH_XIAOGUANGYU = 0,
    90,--// FISH_XIAOCAOYU,
    90,--// FISH_REDAIYU,
    80,--// FISH_DAYANJINYU,
    80,--// FISH_SHUIMU,
    70,--// FISH_SHANWEIYU,
    70,--// FISH_REDAIZIYU,
    60,--// FISH_XIAOCHOUYU,
    60,--// FISH_HETUN,
    50,--// FISH_WUZEI,
    50,--// FISH_SHITOUYU,
    45,--// FISH_SHENXIANYU,
    45,--// FISH_WUGUI,
    40,--// FISH_DENGLONGYU,
    40,--// FISH_SHIBANYU,
    35,--// FISH_HUDIEYU,
    35,--// FISH_LINGDANGYU,
    35,--// FISH_JIANYU,
    30,--// FISH_MOGUIYU,
    30,--// FISH_FEIYU,
    30,--// FISH_LONGXIA,
    25,--// FISH_HAITUN,
    25,--// FISH_DAZHADAN,
    25,--// FISH_FROZEN,
    30,--// FISH_ZHENZHUBEI,
    30,--// FISH_XIAOFEIYU,
    50,--// FISH_ALILAN,
    0,--// FISH_ZHADANFISH,
    0,--// FISH_NORMAL_TYPEMAX (NO USE)
    80,--// FISH_XIAOHUANGCI
    80,--// FISH_LANGUANGYU
    60,--// FISH_QICAIYU
    50,--// FISH_YINGWULUO
    50,--// FISH_TIAOWENYU
    40,--// FISH_GANGKUIYU
    0,--// FISH_HAIGUAI
    0--// FISH_HGZHADAN
};

FishType = {
  FISH_XIAOGUANGYU=1,
  FISH_XIAOCAOYU=2,
  FISH_REDAIYU=3,
  FISH_DAYANJINYU=4,
  FISH_SHUIMU=5,
  FISH_SHANWEIYU=6,
  FISH_REDAIZIYU=7,
  FISH_XIAOCHOUYU=8,
  FISH_HETUN=9,
  FISH_WUZEI=10,
  FISH_SHITOUYU=11,
  FISH_SHENXIANYU=12,
  FISH_WUGUI=13,
  FISH_DENGLONGYU=14,
  FISH_SHIBANYU=15,
  FISH_HUDIEYU=16,
  FISH_LINGDANGYU=17,--
  FISH_JIANYU=18,--鲨鱼
  FISH_MOGUIYU=19,--龙
  FISH_FEIYU=20,--
  FISH_LONGXIA=21,--李逵
  FISH_ZHADAN=22,--定屏炸弹
  FISH_DAZHADAN=23,--局部炸弹
  FISH_FROZEN=24,--超级炸弹
  FISH_ZHENZHUBEI=25,--大三元1
  FISH_XIAOFEIYU=26,--大三元2
  FISH_ALILAN=27,--大三元3
  FISH_ZHADANFISH=28,--大四喜1
  FISH_NORMAL_TYPEMAX=29,--大四喜2
  FISH_WORLDBOSS=30, --大四喜3
  FISH_FENGHUANG=31,  --鱼王1
  FISH_NANGUAXIAO=32, --鱼王2
  FISH_NANGUADA=33, --鱼王3
  FISH_WORLD_TIMER_BOSS =34,--鱼王4
  FISH_GANGKUIYU=35,--鱼王5
  FISH_HAIGUAI=36,--鱼王6
  FISH_HGZHADAN=37,--鱼王7
  FISH_All_TYPEMAX=38,--鱼王8
  FISH_KIND_39=39, --// 鱼王9
  FISH_KIND_40=40, --// 鱼王10
  FISH_BOSS1 = 41,--BOSS
  FISH_BOSS2 = 42,
  FISH_BOSS3 = 43,
  FISH_BOSS4 = 44,
  FISH_HUAFEI1 = 45,--话费鱼--对应15到21的鱼
  FISH_HUAFEI2 = 46,--话费鱼
  FISH_HUAFEI3 = 47,--话费鱼
  FISH_HUAFEI4 = 48,--话费鱼
  FISH_HUAFEI5 = 49,--话费鱼
  FISH_HUAFEI6 = 50,--话费鱼
  FISH_HUAFEI7 = 51,--话费鱼
  FISH_GIFTEGGS = 52,--// 礼蛋
  FISH_ROCKMONEYTREE = 53,-- // 摇钱树
  FISH_REDENVELOPES = 54,-- // 红包
  FISH_YINLONG = 55,-- // 银龙
  FISH_GOLDTORTOISE = 56,-- // 金乌龟
  FISH_CHAOTICBEADS = 57,-- // 混沌珠
  FISH_COLORFULFISH = 58,-- // 七彩鱼
  FISH_HUAFEI8 = 59,
  FISH_KIND_60 = 60, --// 金鲨
  FISH_KIND_61 = 61, --// 美人鱼
  FISH_KIND_62 = 62, --// 船
  FISH_KIND_63 = 63, --// 炼丹炉
  FISH_KIND_64 = 64, --// 一箭双雕
  FISH_KIND_65 = 65, --// 一石三鸟
  FISH_KIND_66 = 66, --// 金玉满堂
  FISH_KIND_67 = 67, --// 出奇制胜1
  FISH_KIND_68 = 68, --// 出奇制胜2
  FISH_KIND_69 = 69, --// 出奇制胜3
  FISH_KIND_70 = 70, --//出奇制胜4
  FISH_KIND_71 = 71, --//出奇制胜5



  FISH_KIND_COUNT = 71,
};

SpecialAttr = {
  SPEC_SANYUAN1=1,
  SPEC_SANYUAN2=2,
  SPEC_SANYUAN3=3,
  SPEC_SIXI1=4,
  SPEC_SIXI2=5,
  SPEC_SIXI3=6,
  SPEC_NONE=7
};

BulletKind={
  BULLET_KIND_1_NORMAL = 0,
  BULLET_KIND_2_NORMAL = 1,
  BULLET_KIND_3_NORMAL = 2,
  BULLET_KIND_4_NORMAL = 3,
  BULLET_KIND_1_ION = 4,
  BULLET_KIND_2_ION = 5,
  BULLET_KIND_3_ION = 6,
  BULLET_KIND_4_ION = 7,
  BULLET_KIND_COUNT = 8,
};

SceneKind ={
  SCENE_KIND_1 = 0,
  SCENE_KIND_2 = 1,
  SCENE_KIND_3 = 2,
  SCENE_KIND_4 = 3,
  SCENE_KIND_5 = 4,

  SCENE_KIND_COUNT
};

function initFishType(selfNode, fishtype ) 

  local self = selfNode;
  self._deadFrameCount = 0;
  self._turnFrameCount = 0;
  self._bodyScale = 1
  self._multiple = fishtype -- 倍数 锁定时用
  self._fishScale = 1
  self._deadSoundCount = 0;

  if(self._fishType == FishType.FISH_XIAOGUANGYU) then --1
      self._activeFrameCount = 7;
      self._activeFrameDelay = 0.1;
      self._scoreRate = 0.25;
      self._attackRate = 150;
      self._speedTime = 20;
      self._genCornNum = 1;
      self._fishCD = 0;
      self._radius = 25;
  elseif(self._fishType == FishType.FISH_XIAOCAOYU) then --2
      self._activeFrameCount = 8;
      self._activeFrameDelay = 0.1;
      self._scoreRate = 0.5;
      self._attackRate = 120;
      self._speedTime = 15;
      self._genCornNum = 1;
      self._fishCD = 0;
      self._radius = 25;
  elseif(self._fishType == FishType.FISH_REDAIYU) then --3
      self._activeFrameCount = 8;
      self._activeFrameDelay = 0.08;
      self._scoreRate = 1;
      self._attackRate = 100;
      self._speedTime = 18;
      self._genCornNum = 1;
      self._fishCD = 0;
      self._radius = 28;
  elseif(self._fishType == FishType.FISH_DAYANJINYU) then --4
      self._activeFrameCount = 8;
      self._activeFrameDelay = 0.08;
      self._scoreRate = 2;
      self._attackRate = 80;
      self._speedTime = 15;
      self._genCornNum = 1;
      self._fishCD = 0;
      self._radius = 28;
  elseif(self._fishType == FishType.FISH_SHUIMU) then --5
      self._activeFrameCount = 9;
      self._activeFrameDelay = 0.1;
      self._scoreRate = 3;
      self._attackRate = 50;
      self._speedTime = 36*0.5;
      self._genCornNum = 1;
      self._fishCD = 0;
      self._radius = 40;
  elseif(self._fishType == FishType.FISH_SHANWEIYU) then --6
      self._activeFrameCount = 8;
      self._activeFrameDelay = 0.2;
      self._scoreRate = 4;
      self._attackRate = 18;
      self._speedTime = 30*0.8;
      self._genCornNum = 1;
      self._fishCD = 0;
      self._radius = 75;
  elseif(self._fishType == FishType.FISH_REDAIZIYU) then --7
      self._activeFrameCount = 8;
      self._activeFrameDelay = 0.08;
      self._scoreRate = 5;
      self._attackRate = 16;
      self._speedTime = 30*0.9;
      self._genCornNum = 1;
      self._fishCD = 0;
      self._radius = 35;
  elseif(self._fishType == FishType.FISH_XIAOCHOUYU) then --8
      self._activeFrameCount = 16;
      self._activeFrameDelay = 0.1;
      self._scoreRate = 6;
      self._attackRate = 14;
      self._speedTime = 30*0.9;
      self._genCornNum = 1;
      self._fishCD = 0;
      self._radius = 40;
  elseif(self._fishType == FishType.FISH_HETUN) then --9
      self._activeFrameCount = 7;
      self._activeFrameDelay = 0.08;
      self._scoreRate = 7;
      self._attackRate = 12;
      self._speedTime = 34*0.6;
      self._genCornNum = 1;
      self._fishCD = 0;
      self._radius = 50;
      elseif(self._fishType == FishType.FISH_WUZEI) then --10
      self._activeFrameCount = 8;
      self._activeFrameDelay = 0.2;
      self._scoreRate = 8;
      self._attackRate = 12;
      self._speedTime = 44*0.6;
      self._genCornNum = 1;
      self._fishCD = 0;
      self._radius = 50;
  elseif(self._fishType == FishType.FISH_SHITOUYU) then --11
      self._activeFrameCount = 8;
      self._scoreRate = 9;
      self._attackRate = 10;
      self._activeFrameDelay = 0.15;
      self._speedTime = 32;
      self._genCornNum = 1;
      self._fishCD = 0;
      self._radius = 35;
      self._deadSoundCount = 2;
  elseif(self._fishType == FishType.FISH_SHENXIANYU) then --12
      self._activeFrameCount = 8;
      self._activeFrameDelay = 0.1;
      self._scoreRate = 10;
      self._attackRate = 10;
      self._speedTime = 40*0.5;
      self._genCornNum = 1;
      self._fishCD = 0;
      self._radius = 40;
      self._deadSoundCount = 2;
  elseif(self._fishType == FishType.FISH_WUGUI) then --13
      self._activeFrameCount = 7;
      self._activeFrameDelay = 0.09;
      self._scoreRate = 12;
      self._attackRate = 11;
      self._speedTime = 32;
      self._genCornNum = 21;
      self._fishCD = 0;
      self._radius = 55;
      self._deadSoundCount = 2;
  elseif(self._fishType == FishType.FISH_DENGLONGYU) then --14
      self._activeFrameCount = 10;
      self._activeFrameDelay = 0.12;
      self._scoreRate = 15;
      self._attackRate = 10;
      self._speedTime = 28;
      self._genCornNum = 21;
      self._fishCD = 0;
      self._radius = 65;
      self._deadSoundCount = 2;
  elseif(self._fishType == FishType.FISH_SHIBANYU) then --15
      self._activeFrameCount = 9;
      self._activeFrameDelay = 0.1;
      self._scoreRate = 18;
      self._attackRate = 9;
      self._speedTime = 32*0.8;
      self._genCornNum = 21;
      self._fishCD = 0;
      self._radius = 112;
      self._deadSoundCount = 2;
  elseif(self._fishType == FishType.FISH_HUDIEYU) then --16
      self._activeFrameCount = 8;
      self._activeFrameDelay = 0.08;
      self._scoreRate = 20;
      self._attackRate = 8;
      self._speedTime = 36*0.9;
      self._genCornNum = 22;
      self._fishCD = 0;
      self._radius = 115;
      self._deadSoundCount = 2;
  elseif(self._fishType == FishType.FISH_LINGDANGYU) then --17
      self._activeFrameCount = 6;
      self._activeFrameDelay = 0.2;
      self._scoreRate = 25;
      self._attackRate = 7;
      self._speedTime = 36*0.9;
      self._genCornNum = 22;
      self._fishCD = 0;
      self._radius = 115;
      self._deadSoundCount = 2;
  elseif(self._fishType == FishType.FISH_JIANYU) then --18   
      self._activeFrameCount = 8;
      self._scoreRate = 50;
      self._attackRate = 3;
      self._activeFrameDelay = 0.08;
      self._speedTime = 60*0.5;
      self._genCornNum = 23;
      self._fishCD = 5;
      self._radius = 150;
      self._fishScale = 1;
      self._deadSoundCount = 2;
  elseif(self._fishType == FishType.FISH_MOGUIYU) then --19
      self._activeFrameCount = 8;
      self._activeFrameDelay = 0.08;
      self._scoreRate = 35;
      self._attackRate = 5;
      self._speedTime = 45*0.5;
      self._genCornNum = 23;
      self._fishCD = 0;
      self._radius = 75;
      self._bodyScale = 1;
      self._fishScale = 1;
      self._bodyScale = self._bodyScale*self._fishScale;
  elseif(self._fishType == FishType.FISH_FEIYU) then --20
      self._activeFrameCount = 14;
      self._scoreRate = 40;
      self._attackRate = 4;
      self._activeFrameDelay = 0.1;
      self._speedTime = 60*0.45;
      self._genCornNum = 23;
      self._fishCD = 5;
      self._radius = 140;
      self._bodyScale = 0.85
      self._fishScale = 0.9;
      self._bodyScale = self._bodyScale*self._fishScale;
  elseif(self._fishType == FishType.FISH_LONGXIA) then --21
      self._activeFrameCount = 7;
      self._activeFrameDelay = 0.2;
      self._scoreRate = 30;
      self._attackRate = 6;
      self._speedTime = 60;
      self._genCornNum = 22;
      self._fishCD = 5;
      self._radius = 133;
      self._fishScale = 1;
      self._deadSoundCount = 3;
      -- self._bodyScale = self._bodyScale*self._fishScale;
  elseif(self._fishType == FishType.FISH_ZHADAN) then --22
      self._activeFrameCount = 7;
      self._activeFrameDelay = 0.1;
      self._scoreRate = 60;
      self._attackRate = 3;
      self._speedTime = 44*0.6;
      self._genCornNum = 24;
      self._fishCD = 5;
      self._radius = 60;
      self._fishScale = 1;
      -- self._bodyScale = self._bodyScale*self._fishScale;
  elseif(self._fishType == FishType.FISH_DAZHADAN) then --23
      self._activeFrameCount = 16;
      self._activeFrameDelay = 0.2;
      self._scoreRate = 80;
      self._attackRate = 2;
      self._speedTime = 44*0.6;
      self._genCornNum = 24;
      self._fishCD = 5;
      self._radius = 75;
      self._scale = 1
  elseif(self._fishType == FishType.FISH_FROZEN) then --24
      self._activeFrameCount = 6;
      self._scoreRate = 100;
      self._attackRate = 2;
      self._activeFrameDelay = 0.1;
      self._speedTime = 44*0.6;
      self._genCornNum = 24;
      self._fishCD = 5;
      self._radius = 55;
      self._scale = 0.8
  elseif(self._fishType == FishType.FISH_ZHENZHUBEI) then --25
      self._activeFrameCount = 9;
      self._activeFrameDelay = 0.1;
      self._scoreRate = 10;
      self._attackRate = 12;
      self._speedTime = 35;
      self._genCornNum = 1;
      self._fishCD = 30;
      self._radius = 35;
  elseif(self._fishType == FishType.FISH_XIAOFEIYU) then --26
      self._activeFrameCount = 8;
      self._activeFrameDelay = 0.1;
      self._scoreRate = 1;
      self._attackRate = 30;
      self._speedTime = 30;
      self._genCornNum = 1;
      self._fishCD = 0;
      self._radius = 70;
  elseif(self._fishType == FishType.FISH_ALILAN) then --27
      self._activeFrameCount = 8;
      self._scoreRate = 1;
      self._activeFrameDelay = 0.15;
      self._attackRate = 30;
      self._speedTime = 30;
      self._genCornNum = 1;
      self._fishCD = 0;
      self._radius = 20;
  elseif(self._fishType == FishType.FISH_ZHADANFISH) then --28
      self._activeFrameCount = 16;
      self._activeFrameDelay = 0.1;
      self._scoreRate = 0;
      self._attackRate = 2;
      self._speedTime = 30;
      self._genCornNum = 0;
      self._fishCD = 0;
      self._radius = 20;
  elseif(self._fishType == FishType.FISH_NORMAL_TYPEMAX) then --29
      self._activeFrameCount = 7;
      self._activeFrameDelay = 0.1;
      self._scoreRate = 0;
      self._attackRate = 2;
      self._speedTime = 30;
      self._genCornNum = 0;
      self._fishCD = 0;
      self._radius = 20;
  elseif(self._fishType == FishType.FISH_WORLDBOSS) then --30
      self._activeFrameCount = 8;
      self._activeFrameDelay = 0.1;
      self._scoreRate = 1;
      self._bodyScale = 1
      self._attackRate = 30;
      self._speedTime = 30;
      self._genCornNum = 1;
      self._fishCD = 0;
      self._radius = 20;
  elseif(self._fishType == FishType.FISH_FENGHUANG) then --31
      self._activeFrameCount = 7;
      self._activeFrameDelay = 0.1;
      self._bodyScale = 1
      self._scoreRate = 1;
      self._attackRate = 30;
      self._speedTime = 20;
      self._genCornNum = 1;
      self._fishCD = 0;
      self._radius = 20;
      self._fishScale = 1;
  elseif(self._fishType == FishType.FISH_NANGUAXIAO) then --32 --小南瓜
      self._activeFrameCount = 8;
      self._activeFrameDelay = 0.08;
      self._scoreRate = 35;
      self._attackRate = 5;
      self._speedTime = 20;
      self._genCornNum = 23;
      self._fishCD = 0;
      self._radius = 75;
      self._bodyScale = 1
      self._fishScale = 1;
      self._bodyScale = self._bodyScale*self._fishScale;
  elseif(self._fishType == FishType.FISH_NANGUADA) then --33 --大南瓜
      self._activeFrameCount = 8;
      self._activeFrameDelay = 0.08;
      self._scoreRate = 35;
      self._attackRate = 5;
      self._speedTime = 20;
      self._genCornNum = 23;
      self._fishCD = 0;
      self._radius = 75;
      self._bodyScale = self._bodyScale*self._fishScale;
  elseif(self._fishType == FishType.FISH_WORLD_TIMER_BOSS) then --34 定时boss
      self._activeFrameCount = 8;
      self._activeFrameDelay = 0.1;
      self._scoreRate = 1;
      self._attackRate = 30;
      self._speedTime = 20;
      self._genCornNum = 1;
      self._fishCD = 0;
      self._radius = 20;
  elseif(self._fishType == FishType.FISH_GANGKUIYU) then --35
      self._activeFrameCount = 9;
      self._activeFrameDelay = 0.1;
      self._scoreRate = 1;
      self._attackRate = 30;
      self._speedTime = 20;
      self._genCornNum = 1;
      self._fishCD = 0;
      self._radius = 20;
  elseif(self._fishType == FishType.FISH_HAIGUAI) then --36
      self._activeFrameCount = 8;
      self._activeFrameDelay = 0.1;
      self._scoreRate = 1;
      self._attackRate = 30;
      self._speedTime = 20;
      self._genCornNum = 1;
      self._fishCD = 0;
      self._radius = 20;
  elseif(self._fishType == FishType.FISH_HGZHADAN) then --37
      self._activeFrameCount = 8;
      self._activeFrameDelay = 0.1;
      self._scoreRate = 1;
      self._attackRate = 30;
      self._speedTime = 20;
      self._genCornNum = 1;
      self._fishCD = 0;
      self._radius = 20;
  elseif(self._fishType == FishType.FISH_All_TYPEMAX) then --38
      self._activeFrameCount = 16;
      self._activeFrameDelay = 0.1;
      self._scoreRate = 1;
      self._attackRate = 30;
      self._speedTime = 20;
      self._genCornNum = 1;
      self._fishCD = 0;
      self._radius = 20;
  elseif(self._fishType == FishType.FISH_KIND_39) then --39
      self._activeFrameCount = 7;
      self._activeFrameDelay = 0.1;
      self._scoreRate = 1;
      self._attackRate = 30;
      self._speedTime = 20;
      self._genCornNum = 1;
      self._fishCD = 0;
      self._radius = 20;
  elseif(self._fishType == FishType.FISH_KIND_40) then --40
      self._activeFrameCount = 8;
      self._activeFrameDelay = 0.1;
      self._scoreRate = 1;
      self._attackRate = 30;
      self._speedTime = 20;
      self._genCornNum = 1;
      self._fishCD = 0;
      self._radius = 20;
  elseif (self._fishType == FishType.FISH_BOSS1) then--41
      self._activeFrameCount = 15;
      self._activeFrameDelay = 0.1;
      self._scoreRate = 1;
      self._attackRate = 30;
      self._speedTime = 60;
      self._genCornNum = 1;
      self._fishCD = 0;
      self._radius = 20;
  elseif (self._fishType == FishType.FISH_BOSS2) then--42
      self._activeFrameCount = 20;
      self._activeFrameDelay = 0.1;
      self._scoreRate = 1;
      self._attackRate = 30;
      self._speedTime = 60;
      self._genCornNum = 1;
      self._fishCD = 0;
      self._radius = 20;
  elseif (self._fishType == FishType.FISH_BOSS3) then--43
      self._activeFrameCount = 17;
      self._activeFrameDelay = 0.1;
      self._scoreRate = 1;
      self._attackRate = 30;
      self._speedTime = 60;
      self._genCornNum = 1;
      self._fishCD = 0;
      self._radius = 20;
  elseif (self._fishType == FishType.FISH_BOSS4) then--44
      self._activeFrameCount = 34;
      self._activeFrameDelay = 0.1;
      self._scoreRate = 1;
      self._attackRate = 30;
      self._speedTime = 60;
      self._genCornNum = 1;
      self._fishCD = 0;
      self._radius = 20;
  elseif(self._fishType == FishType.FISH_HUAFEI1) then --45
      self._activeFrameCount = 12;
      self._activeFrameDelay = 0.09;
      self._scoreRate = 12;
      self._attackRate = 11;
      self._speedTime = 32;
      self._genCornNum = 21;
      self._fishCD = 0;
      self._radius = 55;
      self._deadSoundCount = 2;
  elseif(self._fishType == FishType.FISH_HUAFEI2) then --46
      self._activeFrameCount = 24;
      self._activeFrameDelay = 0.12;
      self._scoreRate = 15;
      self._attackRate = 10;
      self._speedTime = 28;
      self._genCornNum = 21;
      self._fishCD = 0;
      self._radius = 65;
      self._deadSoundCount = 2;
  elseif(self._fishType == FishType.FISH_HUAFEI3) then --47
      self._activeFrameCount = 20;
      self._activeFrameDelay = 0.1;
      self._scoreRate = 18;
      self._attackRate = 9;
      self._speedTime = 32*0.8;
      self._genCornNum = 21;
      self._fishCD = 0;
      self._radius = 112;
      self._deadSoundCount = 2;
  elseif(self._fishType == FishType.FISH_HUAFEI4) then --48
      self._activeFrameCount = 24;
      self._activeFrameDelay = 0.08;
      self._scoreRate = 20;
      self._attackRate = 8;
      self._speedTime = 36*0.9;
      self._genCornNum = 22;
      self._fishCD = 0;
      self._radius = 115;
      self._deadSoundCount = 2;
  elseif(self._fishType == FishType.FISH_HUAFEI5) then --49
      self._activeFrameCount = 14;
      self._activeFrameDelay = 0.08;
      self._scoreRate = 25;
      self._attackRate = 7;
      self._speedTime = 36*0.9;
      self._genCornNum = 22;
      self._fishCD = 0;
      self._radius = 115;
      self._deadSoundCount = 2;
  elseif(self._fishType == FishType.FISH_HUAFEI6) then --50   
      self._activeFrameCount = 18;
      self._scoreRate = 50;
      self._attackRate = 3;
      self._activeFrameDelay = 0.08;
      self._speedTime = 60*0.5;
      self._genCornNum = 23;
      self._fishCD = 5;
      self._radius = 150;
      self._fishScale = 1;
      self._deadSoundCount = 2;
  elseif(self._fishType == FishType.FISH_HUAFEI7) then --51
      self._activeFrameCount = 10;
      self._scoreRate = 40;
      self._attackRate = 4;
      self._activeFrameDelay = 0.1;
      self._speedTime = 60*0.45;
      self._genCornNum = 23;
      self._fishCD = 5;
      self._radius = 140;
      self._bodyScale = 0.85
      self._fishScale = 0.9;
      self._bodyScale = self._bodyScale*self._fishScale;
  elseif(self._fishType == FishType.FISH_GIFTEGGS) then --52
      self._activeFrameCount = 33;
      self._activeFrameDelay = 0.05;
      self._deadFrameCount = 16;
      self._scoreRate = 60;
      self._attackRate = 3;
      self._speedTime = 44*0.6;
      self._genCornNum = 24;
      self._fishCD = 5;
      self._radius = 60;
      self._fishScale = 1.2;
  elseif(self._fishType == FishType.FISH_ROCKMONEYTREE) then --53
      self._activeFrameCount = 61;
      self._activeFrameDelay = 0.1;
      self._deadFrameCount = 17;
      self._scoreRate = 60;
      self._attackRate = 3;
      self._speedTime = 44*0.6;
      self._genCornNum = 24;
      self._fishCD = 5;
      self._radius = 60;
      self._fishScale = 1;
  elseif(self._fishType == FishType.FISH_REDENVELOPES) then --54
      self._activeFrameCount = 61;
      self._activeFrameDelay = 0.05;
      self._deadFrameCount = 16;
      self._scoreRate = 60;
      self._attackRate = 3;
      self._speedTime = 44*0.6;
      self._genCornNum = 24;
      self._fishCD = 5;
      self._radius = 60;
      self._fishScale = 1;
  elseif(self._fishType == FishType.FISH_YINLONG) then --55
      self._activeFrameCount = 8;
      self._activeFrameDelay = 0.1;
      self._scoreRate = 60;
      self._attackRate = 3;
      self._speedTime = 44*0.6;
      self._genCornNum = 24;
      self._fishCD = 5;
      self._radius = 60;
      self._fishScale = 1;
  elseif(self._fishType == FishType.FISH_GOLDTORTOISE) then --56
      self._activeFrameCount = 8;
      self._activeFrameDelay = 0.2;
      self._scoreRate = 60;
      self._attackRate = 3;
      self._speedTime = 44*0.6;
      self._genCornNum = 24;
      self._fishCD = 5;
      self._radius = 60;
      self._fishScale = 1;
  elseif(self._fishType == FishType.FISH_CHAOTICBEADS) then --57
      self._activeFrameCount = 24;
      self._activeFrameDelay = 0.1;
      self._scoreRate = 60;
      self._attackRate = 3;
      self._speedTime = 44*0.6;
      self._genCornNum = 24;
      self._fishCD = 5;
      self._radius = 60;
      self._fishScale = 1;
  elseif(self._fishType == FishType.FISH_COLORFULFISH) then --58
      self._activeFrameCount = 24;
      self._activeFrameDelay = 0.1;
      self._scoreRate = 60;
      self._attackRate = 3;
      self._speedTime = 44*0.6;
      self._genCornNum = 24;
      self._fishCD = 5;
      self._radius = 60;
      self._fishScale = 1;
  elseif(self._fishType == FishType.FISH_HUAFEI8) then --59
      self._activeFrameCount = 6;
      self._activeFrameDelay = 0.2;
      self._scoreRate = 60;
      self._attackRate = 3;
      self._speedTime = 44*0.6;
      self._genCornNum = 24;
      self._fishCD = 5;
      self._radius = 60;
      self._fishScale = 1;
  elseif(self._fishType == FishType.FISH_KIND_64) then --64
      self._activeFrameCount = 7;
      self._activeFrameDelay = 0.08;
      self._scoreRate = 1;
      self._attackRate = 100;
      self._speedTime = 18;
      self._genCornNum = 1;
      self._fishCD = 0;
      self._radius = 28;
  elseif(self._fishType == FishType.FISH_KIND_65) then --65
      self._activeFrameCount = 7;
      self._activeFrameDelay = 0.08;
      self._scoreRate = 1;
      self._attackRate = 100;
      self._speedTime = 18;
      self._genCornNum = 1;
      self._fishCD = 0;
      self._radius = 28;
  elseif(self._fishType == FishType.FISH_KIND_66) then --66
      self._activeFrameCount = 7;
      self._activeFrameDelay = 0.08;
      self._scoreRate = 1;
      self._attackRate = 100;
      self._speedTime = 18;
      self._genCornNum = 1;
      self._fishCD = 0;
      self._radius = 28;
  elseif(self._fishType == FishType.FISH_KIND_67) then --67
      self._activeFrameCount = 8;
      self._activeFrameDelay = 0.08;
      self._scoreRate = 1;
      self._attackRate = 100;
      self._speedTime = 18;
      self._genCornNum = 1;
      self._fishCD = 0;
      self._radius = 28;
  elseif(self._fishType == FishType.FISH_KIND_68) then --68
      self._activeFrameCount = 8;
      self._activeFrameDelay = 0.08;
      self._scoreRate = 2;
      self._attackRate = 80;
      self._speedTime = 18;
      self._genCornNum = 1;
      self._fishCD = 0;
      self._radius = 28;
  elseif(self._fishType == FishType.FISH_KIND_69) then --69
      self._activeFrameCount = 9;
      self._activeFrameDelay = 0.1;
      self._scoreRate = 3;
      self._attackRate = 50;
      self._speedTime = 18;
      self._genCornNum = 1;
      self._fishCD = 0;
      self._radius = 40;
  elseif(self._fishType == FishType.FISH_KIND_70) then --70
      self._activeFrameCount = 8;
      self._activeFrameDelay = 0.2;
      self._scoreRate = 4;
      self._attackRate = 18;
      self._speedTime = 18;
      self._genCornNum = 1;
      self._fishCD = 0;
      self._radius = 75;
  elseif(self._fishType == FishType.FISH_KIND_71) then --71
      self._activeFrameCount = 8;
      self._activeFrameDelay = 0.08;
      self._scoreRate = 5;
      self._attackRate = 16;
      self._speedTime = 18;
      self._genCornNum = 1;
      self._fishCD = 0;
      self._radius = 35;
  else
      luaPrint("------------未定义的鱼的类型------", self._fishType)

      self._fishType = FishType.FISH_XIAOGUANGYU;
      self._activeFrameCount = 10;
      self._deadFrameCount = 0;
      self._scoreRate = 0.25;
      self._attackRate = 150;
      self._activeFrameDelay = 0.06;
      self._speedTime = 20;
      self._genCornNum = 1;
      self._fishCD = 0;
      self._radius = 15;
      self._scale = 1
  end

  self._scale = 1

  return self;
end

function getLocalType( fishtype )

  return fishtype+1;
end

function split(str, reps)
    local resultStrsList = {};
    string.gsub(str, '[^' .. reps ..']+', function(w) table.insert(resultStrsList, w) end );
    return resultStrsList;
end

fishBodyPlistTable = {};

function  getBodyPlistFile(bodyFilePath,fishNode)

    local bodyPlistTable = {};
    bodyPlistTable.fileName = bodyFilePath;
    bodyPlistTable.bodyPointTalbe = {};

    local clothingDict = cc.FileUtils:getInstance():getValueMapFromFile(bodyFilePath)  

    local keyTag = 1;

    local clothing_frame = clothingDict[tostring(keyTag)];  
    while(clothing_frame)do

      local vertPoint = {};

      for i,v in ipairs(clothing_frame) do  
        
          local pointTable = split(v,",");
           
          pointTable[1] = string.gsub(pointTable[1],"{ ","");
          pointTable[2] = string.gsub(pointTable[2]," }","");

          table.insert(vertPoint,cc.p(tonumber(pointTable[1]*fishNode._bodyScale),tonumber(pointTable[2])*fishNode._bodyScale));
      end  
    
      --加入缓存
      table.insert(bodyPlistTable.bodyPointTalbe,vertPoint)
    
      keyTag = keyTag+1;
      clothing_frame = clothingDict[tostring(keyTag)];  
    end

    return bodyPlistTable;
end

function getBodyPlistFileCircle(bodyFilePath,fishNode)
    local bodyPlistTable = {};
    bodyPlistTable.fileName = bodyFilePath;
    bodyPlistTable.bodyPointTalbe = {};

    local clothingDict = cc.FileUtils:getInstance():getValueMapFromFile(bodyFilePath) 

    clothingDict.circle.radius=clothingDict.circle.radius*fishNode._bodyScale;

    bodyPlistTable.bodyPointTalbe = clothingDict.circle;

    return bodyPlistTable;
end

function createBody(bodyPointTable,bodyType)
 
  local body = cc.PhysicsBody:create();
  -- body:setDynamic(false);

  if bodyType == "circle" then
    body:addShape(cc.PhysicsShapeCircle:create(bodyPointTable.radius));
  else
    for i,vertPoint in ipairs(bodyPointTable) do
      body:addShape(cc.PhysicsShapePolygon:create(vertPoint));
    end  
  end

  return body;
end

function getFilePhysicsBody(bodyFilePath,fishNode,bodyType)
  local bodyPlistFile = nil;

  --先查找缓存有没有使用过
  if(#fishBodyPlistTable > 0)then
     for i,value in ipairs(fishBodyPlistTable) do  
        if(value.fileName == bodyFilePath)then
          bodyPlistFile = value;
          break;
        end
     end
  end

  -- luaPrint("bodyFilePath = "..bodyFilePath);

  if(bodyPlistFile == nil)then
    if bodyType == "circle" then
      bodyPlistFile = getBodyPlistFileCircle(bodyFilePath,fishNode);
    else
      bodyPlistFile = getBodyPlistFile(bodyFilePath,fishNode);
    end
    
    table.insert(fishBodyPlistTable,bodyPlistFile);
  end

  return createBody(bodyPlistFile.bodyPointTalbe,bodyType);
end

