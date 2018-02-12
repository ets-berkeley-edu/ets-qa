class Squad < Team

  attr_accessor :parent_team

  def initialize(squad_data)
    squad_data.each { |k, v| public_send("#{k}=", v) }
  end

  SQUADS = [
      MBB_AA = new({code: 'MBB', name: 'Men\'s Baseball', parent_team: Team::BAM}),
      MBK_AA = new({code: 'MBK', name: 'Men\'s Basketball', parent_team: Team::BBM}),
      MCR_AA = new({code: 'MCR', name: 'Men\'s Crew', parent_team: Team::CRM}),
      MFB_AA = new({code: 'MFB', name: 'Football - Other', parent_team: Team::FBM}),
      MFB_DB = new({code: 'MFB-DB', name: 'Football, Defensive Backs', parent_team: Team::FBM}),
      MFB_DL = new({code: 'MFB-DL', name: 'Football, Defensive Line', parent_team: Team::FBM}),
      MFB_MLB = new({code: 'MFB-MLB', name: 'Football, Inside Linebackers', parent_team: Team::FBM}),
      MFB_OL = new({code: 'MFB-OL', name: 'Football, Offensive Line', parent_team: Team::FBM}),
      MFB_OLB = new({code: 'MFB-OLB', name: 'Football, Outside Linebackers', parent_team: Team::FBM}),
      MFB_QB = new({code: 'MFB-QB', name: 'Football, Quarterbacks', parent_team: Team::FBM}),
      MFB_RB = new({code: 'MFB-RB', name: 'Football, Running Backs', parent_team: Team::FBM}),
      MFB_ST = new({code: 'MFB-ST', name: 'Football, Special Teams', parent_team: Team::FBM}),
      MFB_TE = new({code: 'MFB-TE', name: 'Football, Tight Ends', parent_team: Team::FBM}),
      MFB_WR = new({code: 'MFB-WR', name: 'Football, Wide Receivers', parent_team: Team::FBM}),
      MGO_AA = new({code: 'MGO', name: 'Men\'s Golf', parent_team: Team::GOM}),
      MGY_AA = new({code: 'MGY', name: 'Men\'s Gymnastics', parent_team: Team::GYM}),
      MRU_AA = new({code: 'MRU', name: 'Men\'s Rugby', parent_team: Team::RGM}),
      MSC_AA = new({code: 'MSC', name: 'Men\'s Soccer', parent_team: Team::SCM}),
      MSW_AA = new({code: 'MSW', name: 'Men\'s SwimDive - Other', parent_team: Team::SDM}),
      MSW_DV = new({code: 'MSW-DV', name: 'Men\'s SwimDive, Divers', parent_team: Team::SDM}),
      MSW_SW = new({code: 'MSW-SW', name: 'Men\'s SwimDive, Swimmers', parent_team: Team::SDM}),
      MTE_AA = new({code: 'MTE', name: 'Men\'s Tennis', parent_team: Team::TNM}),
      MTR_AA = new({code: 'MTR', name: 'Men\'s TrackCC - Other', parent_team: Team::TOM}),
      MTR_DC = new({code: 'MTR-DC', name: 'Men\'s TrackCC, Distance CC', parent_team: Team::TOM}),
      MTR_JP = new({code: 'MTR-JP', name: 'Men\'s TrackCC, Jumps', parent_team: Team::TOM}),
      MTR_MD = new({code: 'MTR-MD', name: 'Men\'s TrackCC, Middle Dist', parent_team: Team::TOM}),
      MTR_MT = new({code: 'MTR-MT', name: 'Men\'s TrackCC, Multis', parent_team: Team::TOM}),
      MTR_PV = new({code: 'MTR-PV', name: 'Men\'s TrackCC, Pole Vault', parent_team: Team::TOM}),
      MTR_SH = new({code: 'MTR-SH', name: 'Men\'s TrackCC, Sprints Hurdles', parent_team: Team::TOM}),
      MTR_TH = new({code: 'MTR-TH', name: 'Men\'s TrackCC, Throws', parent_team: Team::TOM}),
      MWP_AA = new({code: 'MWP', name: 'Men\'s Water Polo', parent_team: Team::WPM}),
      WBK_AA = new({code: 'WBK', name: 'Women\'s Basketball', parent_team: Team::BBW}),
      WBV_AA = new({code: 'WBV', name: 'Women\'s Beach Volleyball', parent_team: Team::SVW}),
      WCR_AA = new({code: 'WCR', name: 'Women\'s Crew', parent_team: Team::CRW}),
      WFH_AA = new({code: 'WFH', name: 'Women\'s Field Hockey', parent_team: Team::FHW}),
      WGO_AA = new({code: 'WGO', name: 'Women\'s Golf', parent_team: Team::GOW}),
      WGY_AA = new({code: 'WGY', name: 'Women\'s Gymnastics', parent_team: Team::GYW}),
      WLC_AA = new({code: 'WLC', name: 'Women\'s Lacrosse', parent_team: Team::LCW}),
      WSC_AA = new({code: 'WSC', name: 'Women\'s Soccer', parent_team: Team::SCW}),
      WSF_AA = new({code: 'WSF', name: 'Women\'s Softball', parent_team: Team::SBW}),
      WSW_DV = new({code: 'WSW-DV', name: 'Women\'s SwimDive, Divers', parent_team: Team::SDW}),
      WSW_SW = new({code: 'WSW-SW', name: 'Women\'s SwimDive, Swimmers', parent_team: Team::SDW}),
      WTE_AA = new({code: 'WTE', name: 'Women\'s Tennis', parent_team: Team::TNW}),
      WTR_DC = new({code: 'WTR-DC', name: 'Women\'s TrackCC, Distance CC', parent_team: Team::TOW}),
      WTR_JP = new({code: 'WTR-JP', name: 'Women\'s TrackCC, Jumps', parent_team: Team::TOW}),
      WTR_MD = new({code: 'WTR-MD', name: 'Women\'s TrackCC, Middle Dist', parent_team: Team::TOW}),
      WTR_MT = new({code: 'WTR-MT', name: 'Women\'s TrackCC, Multis', parent_team: Team::TOW}),
      WTR_PV = new({code: 'WTR-PV', name: 'Women\'s TrackCC, Pole Vault', parent_team: Team::TOW}),
      WTR_SH = new({code: 'WTR-SH', name: 'Women\'s TrackCC, Sprints Hurdles', parent_team: Team::TOW}),
      WTR_TH = new({code: 'WTR-TH', name: 'Women\'s TrackCC, Throws', parent_team: Team::TOW}),
      WVB_AA = new({code: 'WVB', name: 'Women\'s Volleyball', parent_team: Team::VBW}),
      WWP_AA = new({code: 'WWP', name: 'Women\'s Water Polo', parent_team: Team::WPW})
  ]

end
