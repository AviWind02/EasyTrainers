local FactFlags = {
    RomanceFlags = {
        { id = "judy_romanceable", name = "Judy Romanceable", desc = "Enables Judy as a romance option." },
        { id = "sq030_judy_lover", name = "Judy Lover", desc = "Marks Judy as your current lover." },
        { id = "panam_romanceable", name = "Panam Romanceable", desc = "Enables Panam as a romance option." },
        { id = "sq027_panam_lover", name = "Panam Lover", desc = "Marks Panam as your current lover." },
        { id = "river_romanceable", name = "River Romanceable", desc = "Enables River as a romance option." },
        { id = "sq029_river_lover", name = "River Lover", desc = "Marks River as your current lover." },
        { id = "kerry_romanceable", name = "Kerry Romanceable", desc = "Enables Kerry as a romance option." },
        { id = "sq028_kerry_lover", name = "Kerry Lover", desc = "Marks Kerry as your current lover." }
    },

    StoryOutcomeFlags = {
        { id = "q105_fingers_beaten", name = "Fingers Beaten", desc = "Fingers was disabled but remains alive and accessible." },
        { id = "q105_fingers_dead", name = "Fingers Dead", desc = "Marks Fingers as killed." },
        { id = "q005_jackie_stay_notell", name = "Jackie Left in Car", desc = "Jackie's body was left in the car after the heist." },
        { id = "q005_jackie_to_hospital", name = "Jackie Sent to Vik", desc = "Jackie's body was sent to the ripperdoc." },
        { id = "q005_jackie_to_mama", name = "Jackie Sent to Mama Welles", desc = "Jackie's body was sent to Mama Welles." },
        { id = "q112_takemura_dead", name = "Takemura Dead", desc = "Takemura was killed during his mission." },
        { id = "sq032_johnny_friend", name = "Johnny Friendly Ending", desc = "Sets Johnny to the friend epilogue state (oil fields)." }
    },

    SmartWeaponStates = {
        { id = "mq007_skippy_aim_at_head", name = "Skippy: Stone Cold Killer", desc = "Skippy is in headshot (lethal) mode." },
        { id = "mq007_skippy_goes_emo", name = "Skippy: Emo Mode", desc = "Skippy has switched to non-lethal emo mode." }
    },

    GameplayToggles = {
        { id = "holo_delamain_deep_vehicle_talk", name = "Delamain Phone Portrait Fix", desc = "Disables buggy NPC phone portraits. Toggle if visuals are broken." },
        { id = "q101_enable_side_content", name = "Unlock Act 1 Side Jobs", desc = "Enables access to all Act 1 side content. Save and reload to take effect." }
    },

    LifePathFlags = {
        { id = "q000_street_kid_background", name = "Street Kid Life Path", desc = "Marks V's background as Street Kid." },
        { id = "q000_corpo_background", name = "Corporate Life Path", desc = "Marks V's background as Corporate." },
        { id = "q000_nomad_background", name = "Nomad Life Path", desc = "Marks V's background as Nomad." }
    },

    WorldEventFlags = {
        { id = "warden_amazon_airdropped", name = "Amazon Airdrop: Warden", desc = "Marks the Warden weapon as already airdropped." },
        { id = "ajax_amazon_airdropped", name = "Amazon Airdrop: Ajax", desc = "Marks the Ajax weapon as already airdropped." },
        { id = "crusher_amazon_airdropped", name = "Amazon Airdrop: Crusher", desc = "Marks the Crusher weapon as already airdropped." },
        { id = "kyubi_amazon_airdropped", name = "Amazon Airdrop: Kyubi", desc = "Marks the Kyubi weapon as already airdropped." },
        { id = "grit_amazon_airdropped", name = "Amazon Airdrop: Grit", desc = "Marks the Grit weapon as already airdropped." },
        { id = "nekomata_amazon_airdropped", name = "Amazon Airdrop: Nekomata", desc = "Marks the Nekomata weapon as already airdropped." },
        { id = "mws_wat_02_egg_placed", name = "Iguana Egg Placed", desc = "Indicates the iguana egg has been placed in V's apartment." },
        { id = "mws_wat_02_iguana_hatched", name = "Iguana Hatched", desc = "Triggers the hatching of the iguana in V's home." }
    },

    CensorshipFlags = {
        { id = "chensorship_drugs", name = "Remove: Drugs", desc = "Disables censorship for drug references." },
        { id = "chensorship_gore", name = "Remove: Gore", desc = "Disables censorship for gore and violence." },
        { id = "chensorship_homosexuality", name = "Remove: Homosexuality", desc = "Disables censorship for LGBTQ content." },
        { id = "chensorship_nudity", name = "Remove: Nudity", desc = "Disables censorship for nudity." },
        { id = "chensorship_oversexualized", name = "Remove: Oversexualization", desc = "Disables oversexualized content filters." },
        { id = "chensorship_religion", name = "Remove: Religion", desc = "Disables censorship for religious references." },
        { id = "chensorship_suggestive", name = "Remove: Suggestive Content", desc = "Disables censorship for sexually suggestive content." }
    }
}

local RelationshipTrackingFacts = { -- I wish I was in a relationship :(
    { id = "judy_relationship", name = "Judy Relationship Progress" },
    { id = "panam_relationship", name = "Panam Relationship Progress" },
    { id = "river_relationship", name = "River Relationship Progress" },
    { id = "sq028_kerry_relationship", name = "Kerry Relationship Progress" }
}


return {
    FactFlags = FactFlags,
    RelationshipTrackingFacts = RelationshipTrackingFacts
}