----------------------------------------------------------------
--  Name Generator
----------------------------------------------------------------
--
--  Oblige Level Maker
--
--  Copyright (C) 2008-2009 Andrew Apted
--  Copyright (C) 2008-2009 JohnnyRancid
--  Copyright (C)      2009 Enhas
--
--  This program is free software; you can redistribute it and/or
--  modify it under the terms of the GNU General Public License
--  as published by the Free Software Foundation; either version 2
--  of the License, or (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
----------------------------------------------------------------
--
--  Thanks to "JohnnyRancid" who contributed many of the
--  complete level names and a lot of cool words.
--
--  Thanks to "Enhas" for the PSYCHO names.
--
----------------------------------------------------------------

require 'util'


NAMING_THEMES =
{
  TECH =
  {
    patterns =
    {
      ["%a %n"]    = 60, ["%t %a %n"]    = 17,
      ["%b %n"]    = 60, ["%t %b %n"]    = 17,
      ["%a %b %n"] = 33, ["%t %a %b %n"] = 5,

      ["%s"] = 16,
    },

    lexicon =
    {
      t =
      {
        The=50
      },

      a =
      {
        -- size
        Universal=20, Collosal=20, Prodigious=3,
        Secluded=10, Confined=5, Restricted=3,


        -- location
        Subterrestrial=10, Sub_terra=5,
        Aethereal=10, Hypogean=5,
        Mars=10, Saturn=10, Jupiter=10,
        Deimos=15, Phobos=15, ["Tei Tenga"]=5,

        Covert=20, Occult=10, Preliminary=3, Experimental=3,
        Northern=3, Southern=3, Eastern=3, Western=3,
        Upper=10, Lower=10, Central=15,
        Inner=10, Outer=10, Innermost=3, Outermost=3,
        Auxiliary=10, Primary=20, Prime=5,
        Exterior=10, Subsidiary=3, Ultimate=3,

        -- condition
        Inactive=10, Unsound=10, Eternal=5,
        Advanced=10, Interlock=5, Symbiotic=3,
        Fantastic=3, Incredible=3, Amazing=3,
        Wondrous=3,

        Destructive=20, Unstable=10, Devastated=3,
        Lost=20, Defective=10, Haggard=15, Failed=10,
        Ravished=10, Inanimate=3, Ruptured=3,
        Polluted=10, Putrid=5, Faulty=5,
        Obsolete=15, Abandoned=15,

        -- infestation
        Monstrous=10, Fatal=10, Invaded=3, Overtaken=3,
        Abberant=10, Internecine=10, Noxious=10, Subnormal=10,
        Infested=20, Anomalous=5, Ghostly=10, Lurid=3,
        Subverted=15, Corrupted=7, Contaminated=5,
        Congested=10, Swarming=10,

        -- descriptive
        Extreme=20, Depraved=10, Unnatural=10, Messianic=3,
        Dark=20, Treacherous=10, Frigid=3,
        Deconditioned=10, Dismal=5, Dreaded=5, Cold=10,
        Perverted=5, Doomed=10,
      },

      b =
      {
        -- purpose
        Control=10, Research=10,
        Military=10, Security=5, Defense=5,
        Processing=10, Refueling=5, Supply=15,
        Manufacturing=3, Maintenance=3,
        Industrial=3, Engineering=5,
        Construction=5, Assembly=5, Management=5,
        Development=5, Foundation=5,
        Aegis=3, Stockade=3, Refuge=5,
        Munitions=5, Armament=5, Drainage=5,
        Support=5, Counteraction=3, Holding=5,
        Testing=5, Quarantine=5, Authorization=5,
        Synthesis=5, Unification=3, Loading=5,
        Disposal=5, Dumping=3, Pumping=4, 
        Transfer=3, Mobilization=3, Irrigation=3,
        Communications=5, Operations=5,
        Training=5, Treatment=5, Shipment=5,
        Cooling=5, Coolant=5, Administration=5,
        Distribution=5, Trafficking=5, Singularity=3,
        Programming=5, Security=5, Staging=5, 


        -- descriptive
        Main=20, Provisional=3,
        Planetary=3, Interstellar=7, Entrance=10, Lunar=10,
        Alpha=10, Beta=5, Gamma=10,
        Delta=10, Omega=5, Sigma=3,
        Epsilon=3, Zeta=3, Lambda=3,
        Atlas=3, Promethus=2, Cronus=3, 
        Hyperion=2, Icarus=2, Echo=2,
        Morpheus=2, Eos=2, Orion=2,
        Tiephron=2, UAC=15,


        -- materials / substances
        Power=20, Energy=15, Cargo=10,
        Fuel=5, Rocket=3, Missile=5,
        Blast=15, Oil=3, Nuclear=15,
        Nukage=10, Plutonium=10, Toxin=10,
        Chemical=15, Slige=10, Waste=10,
        Mining=15, Fusion=15, Thermal=10,
        Infrared=10, Radiation=5, Hydro=3,
        Parallax=5, Ultraviolet=5, Slime=7,
        Steel=5, Fluid=3, Iron=3, Combustion=5,
        Steam=5, Carbon=5, Pressure=5, Pyrolosis=3,
        Radioactivity=5, Sludge=3, Particle=3,
        Cadmium=3, Halogen=3, Toxicity=3, Mercury=3,
        Data=10, CPU=5, Freight=5, Wares=3,
        Petrochemical=3, Tesla=5, 

        Computer=10, Composite=15, Synthetic=5,
        Electronics=5, Electrical=5, Diffusion=3,
        Worm_hole=5, Black_hole=5, Teleport=3,
        Hybrid=5, Cryogenic=5, Cryo_=2,
        Robotic=1, Laser=1, Photonic=1, Bio_=2,

        ["I/O"]=5,
      },

      n =
      {
        -- specific places
        Generator=12, Plant=15, Base=30,
        Warehouse=10, Depot=10, Storage=5,
        Lab=15, Laboratory=5,
        Station=20, Reactor=10, Tower=5,
        Refinery=15, Factory=10,
        Gateway=10, Hanger=5, Outpost=10,
        Tunnels=10, Bunker=7, Facility=10,
        Gateway=5, Point=2, Turbine=3,

        Beacon=3, Satellite=10, Pillbox=1,
        Colony=15, Compound=15, Foundry=3,
        Headquarters=2, Observatory=3,
        Shaft=3, Silos=7, Substation=10,

        -- general places
        Complex=20, Center=20,
        Facility=10, Works=2,
        Area=15, Site=10, Zone=10,
        Quadrant=5, Sector=5, Adjunct=3, 
        Platform=5, Port=3, Grid=5,
        Hub=10, Nexus=3, Core=5, 
        Terminal=10, Installation=5,
        Project=5, Experiment=3,
        Infrastructure=5, Annex=5,
        Dock=3, Bay=3, Tributary=5,
        Channel=5, Chamber=5, Quarters=5,
        Relay=5, Section=3, Post=3, 
        Situation=2, Crisis=2, Emergency=2,


        -- weird ones
        Device=5, Machine=5, Network=5,
        Anomaly=10, Portal=7, Apparatus=10,
        System=15, Project=2, Forge=10,
        Dimension=3, Paradox=3, Vortex=5,
        Enigma=5, Artifact=1,
      },

      s =
      {
        -- single complete level names

        ["Alien Carnage"]=10,
        ["Assault"]=10,
        ["Battlezone"]=10,
        ["Bestial Experiment"]=10,
        ["Beyond Earth"]=10,
        ["Blackbody Radiation"]=10,
        ["Blackdamp"]=10,
        ["Breakdown"]=10,
        ["Breeding Chambers"]=10,
        ["Butt End of Space"]=10,
        ["Call to Arms"]=10,
        ["Carnage Command"]=10,
        ["Close Quarters"]=10,
        ["Code Blue"]=10,
        ["Code Red"]=10,
        ["Collapsys"]=10,
        ["Cold Science"]=10,
        ["Cold Reception"]=10, 
        ["Congestion Collapse"]=10,
        ["Dachronix"]=10,
        ["Deconstruction Site"]=10,
        ["Deep Into The Code"]=10,
        ["Defcon Six"]=10,
        ["Defragmentation factor"]=10,
        ["Deja Vu"]=10,
        ["Domino Effect"]=10,
        ["Ectopia"]=10,
        ["Emergency Situation"]=10,
        ["Evacuation Step One"]=10,
        ["Fire Vat"]=10,
        ["Genocidal Genesis"]=10,
        ["Graveyard Orbit"]=10,
        ["Hellclone"]=10,
        ["Hellspawn Spectrum"]=10,
        ["Horrific Signal"]=10,
        ["Ignition!"]=10,
        ["Interstellar Overdrive"]=10,
        ["Judgement Day"]=10,
        ["Launchpad"]=10,
        ["Natas Legenda"]=10,
        ["Lockdown"]=10,
        ["Mayday"]=10,
        ["Motornerve"]=10,
        ["Negative Reinforcement"]=10,
        ["Neon Rapture"]=10,
        ["Network Collapse"]=10,
        ["Neural Butchery"]=10,
        ["Oscillator"]=10,
        ["Panic Attack"]=10,
        ["Paying Ohmage"]=10,
        ["Point Blank"]=10,
        ["Power Surge"]=10,
        ["Power Pulse"]=10,
        ["Pressure Point"]=10,
        ["Propulsion"]=10,
        ["Revolution"]=10,
        ["Shock-Drop"]=10,
        ["Sickbay"]=10,
        ["Skylab"]=10,
        ["Solar Plexus"]=10,
        ["Space Debris"]=10,
        ["Steel Forgery"]=10,
        ["Strike Zone"]=10,
        ["Supernova"]=10,
        ["Systemic Purge"]=10,
        ["Terminal Velocity"]=10,
        ["Terminus"]=10,
        ["The Disruption"]=10,
        ["The Supercharger"]=10,
        ["This Is Not A Drill"]=10,
        ["Turboshaft"]=10,
        ["UAC Crisis"]=10,
        ["Waste Management"]=10,
        ["Wires and Bloodcells"]=10,

        ["Artificial Apathy"]=10,
        ["Blast Radius"]=10,
        ["Celestial Crimes"]=10,
        ["Excessive Exposure"]=10,
        ["False Discharge"]=10,
        ["Galaxy on Fire"]=10,
        ["Gravity Well"]=10,
        ["Higher Voltage"]=10,
        ["Hello Dynamo"]=10,
        ["Hunger for Weapons"]=10,
        ["In a Future World"]=10,
        ["Input-Output"]=10,
        ["Interstellar Starport"]=10,
        ["Nebula Checkpoint"]=10,
        ["No Escape!"]=10,
        ["No Solutions"]=10,
        ["No Way Through"]=10,
        ["Nothing Works"]=10,
        ["Out of Time"]=10,
        ["Quantum Distortion"]=10,
        ["System Overload"]=10,
        ["The Delusion Machine"]=10,
        ["The Emerald Parallax"]=10,
        ["The Mental Abyss"]=10,
        ["The Muon Collective"]=10,
        ["Transportation H.Q."]=10,
        ["Under an Alien Sky"]=10,
        ["Warp Factor 666"]=10,
      },
    },

    divisors =
    {
      a = 10,
      b = 10,
      n = 50,
      s = 300,
    },
  },  -- TECH


  ----------------------------------------

  GOTHIC =
  {
    patterns =
    {
         ["%a %n"] = 55,
      ["%t %a %n"] = 20,

         ["%n of %h"] = 26,
      ["%a %n of %h"] = 14,

      ["%p's %n"]       = 10,
      ["%p's %a %n"]    = 8,
      ["%p's %n of %h"] = 6,

      ["%s"] = 10,
    },

    lexicon =
    {
      t =
      {
        The=50
      },

      p =
      {
        Satan=10, ["The Devil"]=5, Lucifer=2, Helgor=2, 
        Ceren=2, Mephisto=2, Vuradi=2, Oltion=2, Ktulu=2,
        Dozod=2, Draco=2, Kalrac=2, Minotaur=5, Pandora=1,
        Minos=2, Orgel=2, Nergal=2, Odin=2, Balrok=2,
      },

      a =
      {
        -- size
        Monumental=5, Collossal=10, Sprawling=5,
        Small=3, Endless=10,

        -- location
        Underground=10, Subterranean=5,
        Cloaked=3, Hermetic=3,
        Occult=10, Surreptious=15,
        Inner=15, Abysmal=10, Deepest=15,

        -- condition
        Elder=15, Ancient=15, Eternal=5,
        Decrepid=3, Desolate=10, Foul=10,
        Defiled=10, Ruined=5, Forgotten=10,
        Ravished=5, Barren=5, Deadly=3,
        Begrimed=5, Filthy=5, Sloven=5,
        Stagnant=7, Rancid=10, Rotten=15,
        Burning=20, Burnt=5, Scorching=5,
        Melting=5, Red_Hot=5, Fractured=5,
        Vile=15, Revolting=10, Putrid=5,
        Vulgar=5, Wretched=3, Caustic=5,
        Fallen=10, Stinking=1,

        -- contents
        Blood=20, Bloody=5, Blood_filled=3,
        Blood_stained=2, Blood_soaked=3,
        Lava=5, Lava_filled=3, Bleeding=3, 
        Monstrous=15, Monster=5, Zombie=10,
        Demonic=15, Demon=5, Ghoulish=5,
        Wizard=5, Warlock=2, Wiccan=3,
        Haunted=10, Ghostly=15, Ghastly=5,
        Heathen=3, Rat_infested=5, Necromancers=5,
        Baron=5, Cyberdemon=5,

        -- descriptive
        Evil=30, Unholy=20, Wicked=15, Cruel=10,
        Godless=5, God_forsaken=7, Ungodly=3,
        Perverse=5, Hallowed=5, Oppressive=5,
        Uncivilised=2, Unsanctified=2, Profane=5,
        Brutal=20, Grisly=15, Gothic=7, Ungodly=10,
        Mystical=2, Magical=2, Magic=2, Tortuous=10,

        Ominous=20, Terrifying=5, Gruesome=10,
        Gloomy=5, Awful=10, Execrable=10,
        Horrible=10, Horrendous=10,
        Dismal=10, Dank=5, Frightful=5,
        Dreaded=15, Nightmare=5, 
        Screaming=3, Silent=5, Sullen=10,

        Abhorrent=3, Abominable=5, Bestial=5,
        Detested=5, Direful=2, Disastrous=2,
        Execrated=2, Ill_fated=10, Maximum=5,
        Fatal=10, Final=5, Frail=3, Terminal=2,
        Immoral=5, Immortal=3, Impure=5, Utmost=5,
        Loathsome=5, Merciless=7, Sovereign=7,
        Morbid=10, Pestilent=5, Profane=5, Triumph=2,
        Raw=2, Vicious=10, Violent=10, Sheer=10,
        Ceremonial=5, Liturgical=5, Solemn=5, Deistic=5,
        Divine=5, Devout=5, Sacerdotal=5, Desecrated=5,
        Sacred=5, Clerical=5, Accursed=5, Malodorous=5,
        Despicable=2, Heinous=5, Mephitic=2, Peccant=5,
        Sordid=2, Sacreligious=5, Grievous=2, Fetid=2, 
        Ferine=2, Unspiritual=2, Cruel=5, Crass=2,
      },

      n =
      {
        -- places
        Crypt=20, Grotto=15, Tomb=15,
        Chapel=10, Church=7, Mosque=5,
        Graveyard=10, Cloister=5,
        Pit=10, Cavern=10, Cave=5,
        Wasteland=15, Sepulcher=7,
        Ghetto=2, City=5, Well=5, Realm=10,
        Lair=15, Den=7, Domain=10, Hive=5,
        Valley=10, River=5, Catacombs=10,
        Palace=5, Cathedral=5, Chamber=10,
        Hall=7, Rooms=3, Hecatomb=3,

        Labyrinth=5, Dungeon=10, Shores=5,
        Temple=20, Shrine=10, Vault=10, Sanctum=10,
        Spire=10, Arena=3, Swaths=2, Monastery=10,
        Gate=3, Circle=10, Altar=7, Chapel=10,
        Tower=3, Mountains=2, Prison=3, Narthex=5,
        Sanctuary=3, Basillica=3, Morgue=5, Ring=5,

        -- weird ones
        Communion=5, Monolith=5, Crucible=5,
        Excruciation=1, Abnormality=1,
        Hallucination=1, Teracculus=2,
        Ceremony=3, Threshold=1,
        Ache=2, Apocalypse=1, Ressurection=5,
        Absolution=5, Crux=5, Culmination=5,
        Sacrament=5, Plight=5,  
      },

      h =
      {
        Hell=10, Fire=10, Flames=10,
        Horror=10, Terror=10, Death=15,
        Pain=15, Fear=5, Hate=10, Misery=10,
        Limbo=3, Souls=10, Doom=15, Tragedy=10,
        Carnage=10, Gore=5, Shadows=10, Rapine=10,
        Darkness=10, Destruction=5, Famine=10,
        Suffering=5, Torment=10, Torture=10, Heresy=10,
        Iconoclasm=10, Fallacy=10, Defection=10, 
        Blasphemy=10, Infidelity=10, Paganism=10,
        Schism=10, Secularism=10, Sin=10, Mayhem=10,
        Sorrow=10, Trauma=10, Agony=10, Anguish=10,
        Strain=5, Supplication=5, Witchcraft=5,

        Flesh=10, Corpses=10, Bones=10,
        Skulls=10, Whispers=5, Tears=3,
        Dread=5, Fate=5, Locusts=2,
        Treachery=5, Lunacy=5, Woe=5,
        Reckoning=5, 
        Leviathan=5, Baphomet=5,

        ["the Dead"]=10,
        ["the Denizens"]=10,
        ["the Prophets"]=10,
        ["the Damned"]=10,
        ["the Undead"]=10,
        ["the Necromancer"]=10,
        ["the Forsaken"]=10,
        ["the Possessed"]=10,
        ["the Disobedient"]=10,
        ["the Betrayers"]=10,
        ["the Priest"]=10,
        ["the Unmaker"]=10,
        ["the Sick"]=10,
        ["the Unheard"]=10,
        ["the Behemoth"]=10,
        ["the Possessed"]=10,
        ["the Beast"]=10,
        ["the Apostates"]=10,
        ["the Minions"]=10,
        ["the Vicar"]=10,
        ["the Missionary"]=10,
        ["the Antichrist"]=10,
      },

      s =
      {
        -- single complete level names

        ["Absent Savior"]=10,
        ["Absolution Neglect"]=10,
        ["And The Dead Shall Rise"]=10,
        ["Architect of Troubled Sleep"]=10,
        ["Atrocitic Hunt"]=10,
        ["Atrophy of the Soul"]=10,
        ["A Putrid Serenity"]=10,
        ["Aura of Filth"]=10,
        ["A Vile Peace"]=10,
        ["Awaiting Evil"]=10,
        ["Bad Blood"]=10,
        ["Baptised in Parasites"]=10,
        ["Blinded by Fear"]=10, 
        ["Blood Clot"]=10,
        ["Bloodless Unreality"]=10,
        ["Bloodstains"]=10,
        ["Blood Throne"]=10,
        ["Blood Vanity"]=10,
        ["Bonded by Blood"]=10,
        ["Born/Dead"]=10,
        ["Birthplace of Fate"]=10,
        ["Brotherhood of Ruin"]=10,
        ["Cato's Escort"]=10,
        ["Centromere"]=10,
        ["Cocoon of Filth"]=10,
        ["Cocytus"]=10,  
        ["Corpsehaven"]=10,
        ["Cries of Pain"]=10,
        ["Crucifix of the Damned"]=10,
        ["Cynicism of Vitality"]=10,
        ["Dead Inside"]=10,
        ["Death Cycle"]=10,
        ["Death Grate"]=10,
        ["Death Spawn"]=10,
        ["Deathstay"]=10,
        ["Depths of Hatred"]=10,
        ["Desquamation"]=10,
        ["Diamortal"]=10,
        ["Disdain and Anguish"]=10,
        ["Disease"]=10,
        ["Dissidence Volta"]=10,
        ["Dogma Destroyed"]=10,
        ["Elderworld"]=10,
        ["Etherworld"]=10,
        ["Extinction of Mankind"]=10,
        ["Exuviated Offscouring"]=10,
        ["Ezra's Influence"]=10,
        ["Falling Sky"]=10,
        ["Feed of Decay"]=10,
        ["Feign Sympathy"]=10,
        ["Fenchurch"]=10,
        ["Freeze Mentality"]=10,
        ["Gore Galore"]=10,
        ["Guttural Breath"]=10,
        ["Hades"]=10,
        ["Herald of Demons"]=10,
        ["Hope is Dead"]=10,
        ["Human Compost"]=10,
        ["Human Landfill"]=10,
        ["Human Trafficking"]=10,
        ["Incinerated Cross"]=10,
        ["Infected Grave"]=10,
        ["Iniquity Inferior"]=10,
        ["Insolent Terror"]=10,
        ["Internal Darkness"]=10,
        ["Locust Hide"]=10,
        ["Lychgate"]=10,
        ["Mandatory Suicide"]=10,
        ["Manifest Destination"]=10,
        ["Marbellum"]=10,
        ["Meltdown"]=10,
        ["Menzobarranzen"]=10,
        ["Misery"]=10,
        ["Myth of Progress"]=10,
        ["Necessary Death"]=10,
        ["Necromancide"]=10,
        ["Necropolis"]=10,
        ["Necrosis"]=10,
        ["Nomen Luni"]=10,
        ["Octarena"]=10,
        ["Origin of Nausea"]=10,
        ["Panzer Pentagram"]=10,
        ["Paranoia"]=10,
        ["Parasitic Skies"]=10,
        ["Path of a Fallen Angel"]=10,
        ["Pazuzu's Run"]=10,
        ["Pentadrome"]=10,
        ["Perdition's Massacre"]=10,
        ["Punishment Defined"]=10,
        ["Purgation in Molten Metal"]=10,
        ["Purgatorio"]=10,
        ["Red Dream"]=10,
        ["Return to Hell"]=10,
        ["Ripped Intestines"]=10,
        ["Running Scared"]=10,
        ["Saint Scream"]=10,
        ["Sphacelus"]=10,
        ["Satan's Disgust"]=10,
        ["Seven Deadly Sins"]=10,
        ["Shambled Dimension"]=10,
        ["Shannara"]=10,
        ["Sheol"]=10,
        ["Sign of Evil"]=10,
        ["Skinfeast"]=10,
        ["Skin Graft"]=10,
        ["Skullbog"]=10,
        ["Soul Scars"]=10,
        ["Stygiophobia"]=10,
        ["Sympathy Denied"]=10,
        ["Terminal Filth"]=10,
        ["Thinning the Horde"]=10,
        ["Trivial Anguish"]=10,
        ["Vertigone"]=10,
        ["Vomitorium"]=10,
        ["Ziggurat"]=10,
        ["Zoweseandek "]=10,

        ["Divine Intoxication"]=10,
        ["Dying for It"]=10,
        ["Infernal Directorate"]=10,
        ["Glutton for Punishment"]=10,
        ["Gore Soup"]=10,
        ["Kill Thy Neighbor"]=10,
        ["Murderous Intent"]=10,
        ["No Salvation"]=10,
        ["No Sanctuary"]=10,
        ["Out for Revenge"]=10,
        ["Pulse of Depravity"]=10,
        ["Rampage!"]=10,
        ["Rip in Reality"]=10,
        ["Reaper Unleashed"]=10,
        ["Say Thy Prayers!"]=10,
        ["Searching for Sanity"]=10,
        ["Slice 'em Twice!"]=10,
        ["Sorrowful Faction"]=10,
        ["Taste the Blade"]=10,
        ["Thou Art Doomed!"]=10,
        ["Traces of Evil"]=10,
        ["Twists and Turns"]=10,
        ["Vengeance Denied"]=10,
        ["Welcome to the Coalface"]=10,
        ["Where the Devils Spawn"]=10,
        ["You Can't Handle the Noose"]=10,
      }
    },

    divisors =
    {
      p = 3,
      a = 10,
      h = 10,
      n = 50,
      s = 300,
    },
  },  -- GOTHIC


  ----------------------------------------

  URBAN =
  {
    patterns =
    {
         ["%a %n"] = 60,
      ["%t %a %n"] = 15,

      [   "%n of %h"] = 20,
      ["%t %n of %h"] = 12,
      ["%a %n of %h"] = 7,

      ["%s"] = 10,
    },

    lexicon =
    {
      t =
      {
        The=50
      },

      a =
      {
        -- size
        Plethoric=7, Sprawling=10, Unending=7,
        Serpentine=10, Hulking=3, Giant=2, Vast=7,

        -- location
        Arcane=5, Hidden=5, Ethereal=5, Nether_=5,
        Northern=10, Southern=10, Eastern=10, Western=10,
        Upper=5, Lower=10, Central=5,
        Inner=5, Innermost=3,
        Outer=5, Outermost=3,
        Furthest=5, Isolated=10,

        -- condition
        Old=10, Ancient=20, Eternal=7,
        Decrepid=20, Lost=10, Forgotten=10,
        Ravished=10, Barren=20, Deadly=5,
        Stagnant=10, Rancid=5, Rotten=3,
        Flooded=5, Sunken=3, Occult=5,
        Misty=10, Foggy=5, Toxic=2,
        Windy=10, Hazy=3, Distraught=5, Charred=10,
        Urban=10, Bombarded=2, Corrosive=2,

        -- descriptive
        Monstrous=3, Monster=15, Wild=5,
        Demonic=3, Demon=15, Polluted=10,
        Invaded=5, Overtaken=5, Stolen=3,
        Haunted=20, Infected=10, Infested=10,
        Corrupted=15, Corrupt=15, Fateful=5,
        Besieged=10, Contaminated=10,

        Savage=10, Menacing=15, Frightening=10, Creepy=5,
        Dark=30, Darkest=7, Horrible=10, Exotic=5,
        Dismal=10, Dreadful=10, Cold=7, Ugly=2,
        Vacant=15, Empty=7, Lonely=2, Desperate=2,
        Unknown=5, Unexplored=7, Lupine=2,
        Crowded=3,

        Bleak=30, Abandoned=15, Forsaken=10,
        Cursed=20, Wretched=15, Bewitched=5, 
        Forbidden=20, Sinister=10, Hostile=10,
        Mysterious=10, Obscure=10, Living=3,
        Ominous=15, Perilous=15,
        Slaughter=5, Murder=5, Killing=5,
        Catastrophic=5, Whispering=10,
      },

      n =
      {
        City=30, Town=20, Village=10,
        Condominium=10, Condo=5, Citadel=10,
        Plaza=10, Square=5, Kingdom=15,
        Fortress=20, Fort=5, Stronghold=5,
        Palace=20, Courtyard=10, Court=10,
        Hallways=20, Halls=5, Corridors=7,

        Castle=20, Mineshaft=5, Embassy=5,
        House=20, Mansion=10, Manor=10,
        Refuge=5, Sanctuary=5, Asylum=10,
        Dwelling=3, Estate=2, Sewers=2,
        Outpost=5, Keep=3, Slough=3, Temple=3,
        Gate=10, Prison=15, Dens=5, Slums=5,
        Coliseum=2, Chateau=2,

        World=5, Country=10, Zone=10,
        District=10, Precinct=10,
        Dominion=10, Domain=3, Trail=10,
        Region=10, Territory=5, Path=5,
        Neighborhood=3, Environs=2,
        Bypass=2, Barrio=2, Crossing=5,
        Promenade=5, Trek=5, Venture=5,
        Voyage=7, Course=5, 

        Camp=3, Campus=2, Compound=3, Venue=1,
        Harbor=10, Reserve=3, Ward=3,
        Junction=2, Seabed=5, Embankment=3,
        Oasis=2, Odyssey=2, Habitat=2, Soil=10, 
        Scum=5, Remnants=10, Remains=5, Debris=5,
        Refuse=5, Dust=5, 

        Siege=5, Assault=5, Attack=5, Ambush=5,
        Onslaught=5, Stampede=5, Encounter=5,
        Conflict=5,

        -- plurals
        Lands=20, Fields=20, Footprints=5,
        Alleys=10, Docks=10,
        Towers=10, Streets=10, Roads=5,
        Gardens=15, Warrens=5, Quarry=5,
        Crossroads=5, Outskirts=10,
        Suburbs=10, Quarters=10,
        Mines=20, Barracks=5,

        -- weird ones
        Echo=1,
      },

      h =
      {
        Doom=20, Gloom=15, Despair=10, Sorrow=15,
        Horror=20, Terror=10, Death=10,
        Danger=10, Pain=15, Fear=7, Hate=5,
        Desolation=3, Reparation=3, Solace=10,

        Ruin=10, Flames=3, Destruction=5,
        Twilight=5, Midnight=5, Dreams=2,
        Tears=10, Helplessness=2, Misfortune=5,
        Misery=10, Turmoil=5, Decay=5,
        Blood=10, Insanity=5, Delerium=2,
        Sabotage=5, 

        -- residents
        Ghosts=15, Gods=10, Spirits=5,
        Spectres=5, Banshees=5, Phantoms=5,
        Menace=15, Evil=5, Ghouls=5,
        Ogres=5, Denizens=7, Souls=5,
        Spiders=2, Snakes=5, Vermin=5,
        Madmen=2, Mortals=10, Martyrs=5,
        Prophets=5, Prey=5, Crows=5, 
        Fools=1,

        ["the Mad"]=7,
        ["the Sick"]=5,
        ["the Vermin"]=5,
        ["the Stray"]=5,
        ["the Bizarre"]=5,
        ["the Untamed"]=5,
        ["the Night"]=10,
        ["the Poltergeist"]=10,
        ["the Wraith"]=10,
        ["the Phantasm"]=10,
      },

      s =
      {
        -- single complete level names

        ["Afterhours"]=10,
        ["Aftermath"]=10,
        ["Archipelago"]=10,
        ["Armed to the Teeth"]=10,
        ["Arson Anthem"]=10,
        ["A Monster Too Many"]=10,
        ["Bad Company"]=10,
        ["Black and Grey"]=10,
        ["Blind Salvation"]=10,
        ["Blizzard of Glass"]=10,
        ["Burndown"]=10,
        ["Burnout"]=10,
        ["Cacophobia"]=10,
        ["Cisterne"]=10,
        ["Cold Sweat"]=10,
        ["Countdown to Death"]=10,
        ["Course of Decadence"]=10,
        ["Cross Attack"]=10,
        ["Darkness at Noon"]=10,
        ["Dark Apparition"]=10,
        ["Days of Rage"]=10,
        ["Dead End"]=10,
        ["Deadfall"]=10,
        ["Deadlock"]=10,
        ["Deadly Harvest"]=10,
        ["Deadly Visions"]=10,
        ["Dead Silent"]=10,
        ["Dead Zone"]=10,
        ["Demons On The Prey"]=10,
        ["Doomed Society"]=10,
        ["Dropoff"]=10,
        ["Earth Scum"]=10,
        ["Eight Floors Above"]=10,
        ["Endoomed"]=10,
        ["Famine"]=10,
        ["Fatal Doom"]=10,
        ["Forebearer of Grievance"]=10,
        ["Foul Ruin"]=10,
        ["God's Little Acre"]=10,
        ["Graveyard Shift"]=10,
        ["Hidden Screams"]=10,
        ["Hiding the Secrets"]=10,
        ["Jailbird"]=10,
        ["Kitchen Ace"]=10,
        ["Left for Dead"]=10,
        ["Left in the Cold"]=10,
        ["Lights Out!"]=10,
        ["Lucid Illusion"]=10,
        ["Lunatic Fringe"]=10,
        ["Mayhem"]=10,
        ["New Beginning"]=10,
        ["Nightfall"]=10,
        ["Night Terrors"]=10,
        ["No Rest No Peace"]=10,
        ["Nothing's There"]=10,
        ["On the Hunt"]=10,
        ["Open Wound"]=10,
        ["Overtime"]=10,
        ["Patron of Antipathy"]=10,
        ["Point of No Return"]=10,
        ["Poison Society"]=10,
        ["Polygraph"]=10,
        ["Red Valhalla"]=10,
        ["Retribution"]=10,
        ["Roadkill"]=10,
        ["Roctagon"]=10,
        ["Rotten Roots"]=10,
        ["Running of the Bulls"]=10,
        ["Sanctuary"]=10,
        ["Shellshock"]=10,
        ["Shadowland"]=10,
        ["Stakeout"]=10,
        ["Stonegate"]=10,
        ["Subjugated"]=10,
        ["Suspense"]=10,
        ["Terminal Fear"]=10,
        ["Ten Degrees of Fate"]=10,
        ["The Healer Stalks"]=10,
        ["The Hook"]=10,
        ["The Silenced Lamasery"]=10,
        ["The Trial"]=10,
        ["Tombstone"]=10,
        ["Unleashed Aggression"]=10,
        ["Urban Horror"]=10,
        ["Viscera"]=10,
        ["Voice of the Voiceless"]=10,
        ["Walk of Faith"]=10,
        ["Warzone"]=10,
        ["Watch it Burn"]=10,
        ["Watch your Step"]=10,
        ["When Ashes Rise"]=10,
        ["Witch Parade"]=10,
        ["Xenophobia"]=10,

        ["Ambushed!"]=10,
        ["Bullet Hole"]=10,
        ["Civil Disobedience"]=10,
        ["Disestablishment"]=10,
        ["Eaten by the Furniture"]=10,
        ["Escape is Futile"]=10,
        ["Fight That!"]=10,
        ["Forboding Signs"]=10,
        ["Mindless Architecture"]=10,
        ["Mow 'em Down!"]=10,
        ["Nobody's Home"]=10,
        ["No Comfort"]=10,
        ["Out of Luck"]=10,
        ["Passing Away"]=10,
        ["Route to Death"]=10,
        ["Stream of Unconsciousness"]=10,
        ["Struggle No More"]=10,
        ["Today You Die!"]=10,
        ["Ups and Downs"]=10,
        ["You Don't Belong Here"]=10,
      },
    },

    divisors =
    {
      a = 10,
      h = 10,
      n = 50,
      s = 300,
    },
  },  -- URBAN


  ----------------------------------------

  BOSS =
  {
    patterns =
    {
      ["%s"] = 10,
    },

    lexicon =
    {
      s =
      {
        ["Aftershock"]=10,
        ["Angelic Exodus"]=10,
        ["Arena of Terror"]=10,
        ["Bad Dream"]=10,
        ["Bad Neighbors"]=10,
        ["Barons' Rhapsody"]=10,
        ["Battle Royale"]=10,
        ["Blast Through"]=10,
        ["Bleed on Me"]=10,
        ["Blessed Are the Quick"]=10,
        ["Boss Cage"]=10,
        ["Caughtyard"]=10,
        ["Checkmate"]=10,
        ["Close Combat"]=10,
        ["Coliseum"]=10,
        ["Cyberstomp"]=10,
        ["Deicide Ultra"]=10,
        ["Deliverance"]=10,
        ["Die Hard"]=10,
        ["Dog Eat Dog"]=10,
        ["Do or Die"]=10,
        ["Entombed"]=10,
        ["Eye for an Eye"]=10,
        ["Fatality"]=10,
        ["Final Fight"]=10,
        ["Fire Amok"]=10,
        ["Gladiator"]=10,
        ["Ground Zero"]=10,
        ["Guardian"]=10,
        ["Halloween"]=10,
        ["Hard Attack"]=10,
        ["Hardball"]=10,
        ["Hellmouth"]=10,
        ["Kill Frenzy"]=10,
        ["Killswitch"]=10,
        ["Kingdom Come"]=10,
        ["Knockout"]=10,
        ["Limbo"]=10,
        ["Lions Den"]=10,
        ["Melee!"]=10,
        ["Mission Improbable"]=10,
        ["Moving Target"]=10,
        ["Murderplay"]=10,
        ["Nemesis"]=10,
        ["No Exit!"]=10,
        ["No Sweat"]=10,
        ["Not So Simple"]=10,
        ["Nucleus"]=10,
        ["Open Fire"]=10,
        ["Origin of Venom"]=10,
        ["Panic Room"]=10,
        ["Perfect Conflict"]=10,
        ["Playground"]=10,
        ["Proving Grounds"]=10,
        ["Punchline"]=10,
        ["Razor's Edge"]=10,
        ["Recess"]=10,
        ["Rip and Tear"]=10,
        ["Sealed Fate"]=10,
        ["Showdown"]=10,
        ["Sinister"]=10,
        ["Sink or Swim"]=10,
        ["Six Feet Under"]=10,
        ["Soul Trap"]=10,
        ["Sudden Death"]=10,
        ["The New Fury"]=10,
        ["The Purge"]=10,
        ["The Second Coming"]=10,
        ["The Trap"]=10,
        ["Total Doom"]=10,
        ["Trial by Fire"]=10,
        ["Trouble in Paradise"]=10,
        ["Unmaker"]=10,
        ["Unwelcome"]=10,
        ["Victory Zero"]=10,
      },
    },

    divisors =
    {
      s = 300,
    },
  },  -- BOSS


  ----------------------------------------

  PSYCHO =
  {
    patterns =
    {
      ["%s"] = 10,
    },

    lexicon =
    {
      s =
      {
        -- soap operas, lol

        ["Another World"]=10,
        ["Days of our Lives"]=10,
        ["Guiding Light"]=10,
        ["One Life to Live"]=10,
        ["Passions"]=10,

        -- foods
   
        ["Alphabet Soup"]=10,
        ["Banana Split"]=10,
        ["Broccoli!"]=10,
        ["Chow Mein"]=10,
        ["Fried Chicken"]=10,
        ["Liver and Onions"]=10,
        ["Moldy Bread"]=10,
        ["Raspberry Cheesecake"]=10,
        ["Seedless Watermelon"]=10,
        ["Swedish Meatballs"]=10,

        -- others

        ["99 Cents"]=10,
        ["Axis of Evil"]=10,
        ["Bait the Hook"]=10,
        ["Catapult!"]=10,
        ["Cyberdemon's Clubhouse"]=10,
        ["Disco Inferno"]=10,
        ["Don't Feed the Demons"]=10,
        ["E for Effort"]=10,
        ["ERROR: No Level Name."]=10,
        ["Magnitude 10"]=10,
        ["Moonwalk"]=10,
        ["No Clue"]=10,
        ["Omega-Kappa-Beta Outpost"]=10,
        ["Over the Rainbow"]=10,
        ["Paper Cut"]=10,
        ["Press Alt + F4 for God Mode!"]=10,
        ["This is Not a Hangar Remake"]=10,
        ["You Will Oblige"]=10,
        ["You'll Shoot Your Eye Out"]=10,
        ["Zone of a Thousand Deaths"]=10,
      },
    },

    divisors =
    {
      s = 300,
    },
  },  -- PSYCHO
}


NAMING_IGNORE_WORDS =
{
  ["the"]=1, ["a"]=1,  ["an"]=1, ["of"]=1, ["s"]=1,
  ["for"]=1, ["in"]=1, ["on"]=1, ["to"]=1,
}


function Name_fixup(name)
  -- convert "_" to "-"
  name = string.gsub(name, "_ ", "-")
  name = string.gsub(name, "_",  "-")

  -- convert "A" to "AN" where necessary
  name = string.gsub(name, "^[aA] ([aAeEiIoOuU])", "An %1")

  return name
end


function Naming_split_word(tab, word)
  for w in string.gmatch(word, "%a+") do
    local low = string.lower(w)

    if not NAMING_IGNORE_WORDS[low] then
      -- truncate to 4 letters
      if #low > 4 then
        low = string.sub(low, 1, 4)
      end

      tab[low] = (tab[low] or 0) + 1
    end
  end
end


function Naming_match_parts(word, parts)
  for p,_ in pairs(parts) do
    for w in string.gmatch(word, "%a+") do
      local low = string.lower(w)

      -- truncate to 4 letters
      if #low > 4 then
        low = string.sub(low, 1, 4)
      end

      if p == low then
        return true
      end
    end
  end

  return false
end


function Name_from_pattern(DEF)
  local name = ""
  local words = {}

  local pattern = rand_key_by_probs(DEF.patterns)
  local pos = 1

  while pos <= #pattern do
    
    local c = string.sub(pattern, pos, pos)
    pos = pos + 1

    if c ~= "%" then
      name = name .. c
    else
      assert(pos <= #pattern)
      c = string.sub(pattern, pos, pos)
      pos = pos + 1

      if not string.match(c, "%a") then
        error("Bad naming pattern: expected letter after %")
      end

      local lex = DEF.lexicon[c]
      if not lex then
        error("Naming theme is missing letter: " .. c)
      end

      local w = rand_key_by_probs(lex)
      name = name .. w

      Naming_split_word(words, w)
    end
  end

  return name, words
end


function Name_choose_one(DEF, seen_words, max_len)

  local name, parts

  repeat
    name, parts = Name_from_pattern(DEF)
  until #name <= max_len

  -- adjust probabilities
  for c,divisor in pairs(DEF.divisors) do
    for w,prob in pairs(DEF.lexicon[c]) do
      if Naming_match_parts(w, parts) then
        DEF.lexicon[c][w] = prob / divisor
      end
    end
  end

  return Name_fixup(name)
end


function Naming_gen_list(theme, count, max_len)
 
  local defs = deep_copy(NAMING_THEMES)

  if GAME.naming_themes then
    deep_merge(defs, GAME.naming_themes)
  end
 
  local DEF = defs[theme]
  if not DEF then
    error("Naming_generate: unknown theme: " .. tostring(theme))
  end

  local list = {}
  local seen_words = {}

  for i = 1, count do
    local name = Name_choose_one(DEF, seen_words, max_len)

    table.insert(list, name)
  end

  return list
end


function Naming_grab_one(theme)
  if not GAME.name_cache then
    GAME.name_cache = {}
  end

  if not GAME.name_cache[theme] or table_empty(GAME.name_cache[theme]) then
    GAME.name_cache[theme] = Naming_gen_list(theme, 30, PARAM.max_name_length)
  end

  return table.remove(GAME.name_cache[theme], 1)
end


function Naming_test()
  local function test_theme(T)
    for set = 1,30 do
      gui.rand_seed(set)
      local list = Naming_generate(T, 12, 28)

      for i,name in ipairs(list) do
        gui.debugf("%s Set %d Name %2d: %s\n", T, set, i, name)
      end

      gui.debugf("\n");
    end
  end

  test_theme("TECH")
  test_theme("GOTHIC")
  test_theme("URBAN")
end

