# amend DB connection
connection: "db-platform-sol-cm"

# include all the views + dashboards
include: "/**/*.view"
include: "/dashboards/*.dashboard"

persist_for: "24 hours"

datagroup: new_day {
  sql_trigger: SELECT max(date(_PARTITIONTIME)) from ${impression.SQL_TABLE_NAME}
    where _PARTITIONTIME >= TIMESTAMP(DATE_ADD(CURRENT_DATE, INTERVAL -60 DAY)) ;;
}

map_layer: dma {
  file: "/map_layers/dma.topojson"
  property_key: "dma"
}


explore: impression {
  label: "(1) Impressions"
  view_label: "Impressions"

  sql_always_where: ${impression_raw} > TIMESTAMP(DATE_ADD(CURRENT_DATE, INTERVAL -60 DAY)) ;;

  join: match_table_ads {
    view_label: "Ads"
    sql_on: ${impression.ad_id} = ${match_table_ads.ad_id} ;;
    relationship: many_to_one
  }

  join: match_table_campaigns {
    view_label: "Campaigns"
    sql_on: ${impression.campaign_id} = ${match_table_campaigns.campaign_id} ;;
    relationship: many_to_one
  }

  join: match_table_advertisers {
    view_label: "Advertisers"
    sql_on: ${impression.advertiser_id} = ${match_table_advertisers.advertiser_id} ;;
    relationship: many_to_one
  }

  join: match_table_ad_placement_assignments {
    view_label: "Ad Placements"
    sql_on: ${impression.ad_id} = ${match_table_ad_placement_assignments.ad_id} and ${impression.placement_id} = ${match_table_ad_placement_assignments.placement_id} ;;
    relationship: many_to_one
  }

  join: match_table_browsers {
    view_label: "Browsers"
    sql_on: ${impression.browser_platform_id} = ${match_table_browsers.browser_platform_id} ;;
    relationship: many_to_one
  }

  join: match_table_creatives {
    view_label: "Creatives"
    sql_on: ${impression.rendering_id} = ${match_table_creatives.rendering_id} ;;
    relationship: many_to_one
  }
  join: match_table_operating_systems {
    view_label: "Operating System"
    sql_on: ${impression.operating_system_id_key} = ${match_table_operating_systems.operating_system_id_key} ;;
    relationship: many_to_one
  }

  join: user_impression_facts {
    relationship: one_to_one
    sql_on: ${impression.user_id} = ${user_impression_facts.user_id} and ${impression.campaign_id} = ${user_impression_facts.campaign_id} ;;
  }

}

explore: impression_funnel {
  label: "(2) Impression Funnel"

  sql_always_where: TIMESTAMP(${first_ad_impression_date}) > TIMESTAMP(DATE_ADD(CURRENT_DATE, INTERVAL -60 DAY))  ;;

  join: match_table_campaigns {
    view_label: "Campaigns"
    sql_on: ${impression_funnel.campaign_id} =  ${match_table_campaigns.campaign_id} ;;
    relationship: many_to_one
  }

  join: match_table_ads {
    view_label: "Ads"
    sql_on: ${impression_funnel.ad_id} = ${match_table_ads.ad_id} ;;
    relationship: many_to_one
  }

  join: match_table_advertisers {
    view_label: "Advertisers"
    sql_on: ${impression_funnel.advertiser_id} = ${match_table_advertisers.advertiser_id} ;;
    relationship: many_to_one
  }

  join: user_campaign_facts {
    view_label: "Users"
    sql_on: ${impression_funnel.campaign_id} = ${user_campaign_facts.campaign_id} AND ${impression_funnel.user_id} = ${user_campaign_facts.user_id} ;;
    relationship: many_to_one
  }
}

explore: impression_funnel_dv360 {
  view_label: "DV360 Events"
  label: "(2.5) Impression Funnel DV360"
  description: "Use this funnel explore for a more granular view at cost and impression metrics for DV360 campaigns"
  join: dynamic_io_rank {
    type: left_outer
    relationship: many_to_one
    sql_on: ${impression_funnel_dv360.dbm_insertion_order_id} = ${dynamic_io_rank.dbm_insertion_order_id} ;;
  }

  join: campaign_facts {
    type: left_outer
    relationship: many_to_one
    sql_on: ${impression_funnel_dv360.campaign_id} = ${campaign_facts.campaign_id} ;;
  }

  join: io_facts {
    type: left_outer
    relationship: many_to_one
    sql_on: ${impression_funnel_dv360.dbm_insertion_order_id} = ${io_facts.dbm_insertion_order_id} ;;
  }

  join: line_item_facts {
    type: left_outer
    relationship: many_to_one
    sql_on: ${impression_funnel_dv360.dbm_line_item_id} = ${line_item_facts.dbm_line_item_id} ;;
  }

  join: dbm_matching_targeted_segments_array {
    view_label: "DV360 Events"
    sql: LEFT JOIN UNNEST(${impression_funnel_dv360.dbm_matching_targeted_segments_array}) as dbm_matching_targeted_segments_array ;;
    relationship: one_to_many
  }
}

explore: activity {
  label: "(3) Activities"
  view_label: "Activities"

  sql_always_where: ${activity_raw} > TIMESTAMP(DATE_ADD(CURRENT_DATE, INTERVAL -60 DAY)) ;;

  join: match_table_ads {
    view_label: "Ads"
    sql_on: ${activity.ad_id} = ${match_table_ads.ad_id} ;;
    relationship: many_to_one
  }

  join: match_table_campaigns {
    view_label: "Campaigns"
    sql_on: ${activity.campaign_id} = ${match_table_campaigns.campaign_id} ;;
    relationship: many_to_one
  }

  join: match_table_advertisers {
    view_label: "Advertisers"
    sql_on: ${activity.advertiser_id} = ${match_table_advertisers.advertiser_id} ;;
    relationship: many_to_one
  }

  join: match_table_ad_placement_assignments {
    view_label: "Ad Placements"
    sql_on: ${activity.ad_id} = ${match_table_ad_placement_assignments.ad_id} and ${activity.placement_id} = ${match_table_ad_placement_assignments.placement_id} ;;
    relationship: many_to_one
  }

  join: match_table_browsers {
    view_label: "Browsers"
    sql_on: ${activity.browser_platform_id} = ${match_table_browsers.browser_platform_id} ;;
    relationship: many_to_one
  }
}

explore: click {
  label: "(4) Clicks"
  view_label: "Clicks"

  sql_always_where: ${click_raw} > TIMESTAMP(DATE_ADD(CURRENT_DATE, INTERVAL -60 DAY)) ;;

  join: match_table_ads {
    view_label: "Ads"
    sql_on: ${click.ad_id} = ${match_table_ads.ad_id} ;;
    relationship: many_to_one
  }

  join: match_table_campaigns {
    view_label: "Campaigns"
    sql_on: ${click.campaign_id} = ${match_table_campaigns.campaign_id} ;;
    relationship: many_to_one
  }

  join: match_table_advertisers {
    view_label: "Advertisers"
    sql_on: ${click.advertiser_id} = ${match_table_advertisers.advertiser_id} ;;
    relationship: many_to_one
  }

  join: match_table_ad_placement_assignments {
    view_label: "Ad Placements"
    sql_on: ${click.ad_id} = ${match_table_ad_placement_assignments.ad_id} and ${click.placement_id} = ${match_table_ad_placement_assignments.placement_id} ;;
    relationship: many_to_one
  }

  join: match_table_browsers {
    view_label: "Browsers"
    sql_on: ${click.browser_platform_id} = ${match_table_browsers.browser_platform_id} ;;
    relationship: many_to_one
  }
}

explore: data_health_check {
  label: "(5) Data Health Check"
  view_name: redaction_combined
  always_filter: {
    filters: [redaction_combined.partition: "last 7 days"]
  }
}
