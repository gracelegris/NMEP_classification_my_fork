# ==========================================================================================================================================
# Script Name: Clean ITN ward names
# Purpose: Clean ward names in ITN datasets and resave them for use in the R package/reprioritization.
#          Ensures consistency of names with extracted data.
# Author: Grace Legris, Research Data Analyst, gracebea@gmail.com
# ==========================================================================================================================================

source("load_path.R")
PackageDataDir <- file.path(DriveDir, "data/nigeria/R_package_data")

## =========================================================================================================================================
### KATSINA
## =========================================================================================================================================

# read in ITN data and extracted data
katsina_itn_data <- readxl::read_excel(file.path(ITNDir, "pbi_distribution_Katsina.xlsx"), sheet = 1)
katsina_extracted_data <- read.csv(file.path(ExtractedDir, "Katsina_wards_variables.csv"))  %>%
  arrange(WardName)
katsina_shapefile <- st_read(file.path(StateShpDir, "Katsina/Katsina_state.shp"))

katsina_itn_clean <- katsina_itn_data %>%
  rename(Ward = `AdminLevel3`) %>%
  dplyr::select(population = `N_FamilyMembers`, Ward) %>%
  group_by(Ward) %>%
  summarise(Population = sum(population, na.rm = TRUE)) %>%
  ungroup()

# add lga back
katsina_itn_clean <- katsina_itn_clean %>%
  left_join(katsina_itn_data %>%
              dplyr::select(AdminLevel3, AdminLevel2) %>%
              distinct(), by = c("Ward" = "AdminLevel3")) %>% 
  rename(LGA = AdminLevel2)

katsina_itn_clean <- katsina_itn_clean %>% 
  mutate(Ward = case_when(
    Ward == "Ang Musa" ~ "Anguwan Musa",
    Ward == "Ba'Awa" ~ "Ba'awa",
    Ward == "Babba Mutum" ~ "Babban Mutum",
    Ward == "Bagagadi" ~ "Bugagadi",
    Ward == "Barde/Kkw" ~ "Barde Kwantakwaran",
    Ward == "Borin Dawa" ~ "Borindawa",
    Ward == "Dan Alhaji" ~ "Dan Alhaji Yangayya",
    Ward == "Dan Kum" ~ "Dankum",
    Ward == "Dan'Aunai" ~ "Dan Aunai",
    Ward == "Danali" ~ "Dan Ali",
    Ward == "Danjanku" ~ "Danjanku-Karachi",
    Ward == "Danmarabu" ~ "Dan Murabu",
    Ward == "Danmusa A" ~ "Dan Musa A",
    Ward == "Danmusa B" ~ "Dan Musa B",
    Ward == "Dantakari" ~ "Dantankari",
    Ward == "Darini/ Magaji Abu" ~ "Darini Magaji Abu",
    Ward == "Daunaka/Bakin Kwari" ~ "Daunaka",
    Ward == "Dawan Musa" ~ "Dawa Musa",
    Ward == "Dudunni" ~ "Duddunni",
    Ward == "Dungun Muazu" ~ "Dugu Muazu",
    Ward == "Dutsin Kura" ~ "Dutsen Kura",
    Ward == "Dutsinma A" ~ "Dutsin Ma A",
    Ward == "Dutsinma B" ~ "Dutsin Ma B",
    Ward == "Duwan/Makau" ~ "Duwan Makau",
    Ward == "Fakuwa/Kafin Dangi" ~ "Fakuwa Kafin Dangi",
    Ward == "Gafia" ~ "Gafiya",
    Ward == "Gora Dansaka" ~ "Gora Dan Saka",
    Ward == "Kahutu A" ~ "Kahuta A",
    Ward == "Kahutu B" ~ "Kahuta B",
    Ward == "Kandawa /Jobe" ~ "Kandawa",
    Ward == "Karadua" ~ "Karaduwa",
    Ward == "Katare" ~ "Ketare",
    Ward == "Kawarin Malama" ~ "K Malamai",
    Ward == "Kudi 1" ~ "Kudu 1",
    Ward == "Kudi 2" ~ "Kudu 2",
    Ward == "Kudi 3" ~ "Kudu 3",
    Ward == "Kunduru/Gyaza" ~ "Kunduru Gyaza",
    Ward == "Kurami/Yankwani" ~ "Kurami Yankwani",
    Ward == "Magama/Masabo/Kurabau" ~ "Magama Masabo Kurabau",
    Ward == "Maiadua A" ~ "Mai'adua A",
    Ward == "Maiadua B" ~ "Mai'adua B",
    Ward == "Maiadua C" ~ "Mai'adua C",
    Ward == "Maigora" ~ "Mai Gora",
    Ward == "Mairuwa" ~ "Mairua",
    Ward == "Maje/Karare" ~ "Maje Karare",
    Ward == "Muduri" ~ "Mudiri",
    Ward == "Na Alma" ~ "Na'alma",
    Ward == "Ruma" ~ "Rumah",
    Ward == "Sabongari" ~ "Sabon Gari",
    Ward == "Sarikin Yara B" ~ "Sarkin Yara B",
    Ward == "Tabanni" ~ "Tabanni-Yarraddau",
    Ward == "Tafashiya/ Nassarawa" ~ "Tafashiya Nasarawa",
    Ward == "Tama/Daye" ~ "Tama",
    Ward == "Tsa/Magam" ~ "Tsa Magam",
    Ward == "Tsagem / Takusheyi" ~ "Tsagem Takusheyi",
    Ward == "Uban Dawaki A" ~ "Ubandawaki A",
    Ward == "Uban Dawaki B" ~ "Ubandawaki B",
    Ward == "Yanmama" ~ "Yarmama",
    Ward == "Yargayya" ~ "Yangayya",
    Ward == "Yau Yau/ Mallamawa" ~ "Yau-Yau Malamawa",
    Ward == "Yaya/Bidore" ~ "Yaya",
    TRUE ~ Ward
  ))  %>%
  arrange(Ward) %>% 
  dplyr::select(Ward, LGA, Population)

# identify mismatches between cleaned ITN data and extracted data
itn_unique <- unique(katsina_itn_clean$Ward)
extracted_unique <- unique(katsina_extracted_data$WardName)
missing_in_extracted <- setdiff(itn_unique, extracted_unique)
missing_in_itn <- setdiff(extracted_unique, itn_unique)
cat("Wards in ITN data but not in extracted data:\n")
print(missing_in_extracted)
cat("\nWards in extracted data but not in ITN data:\n")
print(missing_in_itn)

# identify mismatches between cleaned ITN data and shapefile
itn_unique <- unique(katsina_itn_clean$Ward)
shapefile_unique <- unique(katsina_shapefile$WardName)
missing_in_shapefile <- setdiff(itn_unique, shapefile_unique)
missing_in_itn <- setdiff(shapefile_unique, itn_unique)
cat("Wards in ITN data but not in shapefile:\n")
print(missing_in_shapefile)
cat("\nWards in shapefile but not in ITN data:\n")
print(missing_in_itn)

# save cleaned ITN data
writexl::write_xlsx(katsina_itn_clean, file.path(PackageDataDir, "ITN/pbi_distribution_Katsina_clean.xlsx"))

# save cleaned shapefile
st_write(katsina_shapefile, file.path(PackageDataDir, "shapefiles/Katsina/Katsina.shp"), delete_layer = TRUE)

## =========================================================================================================================================
### DELTA
## =========================================================================================================================================

# read in ITN data and extracted data
delta_itn_data <- readxl::read_excel(file.path(ITNDir, "original full ITN datasets/pbi_distribution_Delta.xlsx"))
delta_extracted_data <- read.csv(file.path(ExtractedDir, "Delta_wards_variables.csv"))
delta_shapefile <- st_read(file.path(StateShpDir, "Delta/Delta_state.shp"))

delta_itn_clean <- delta_itn_data %>%
  rename(Ward = `AdminLevel3`) %>%
  dplyr::select(population = `N_FamilyMembers`, Ward) %>%
  group_by(Ward) %>%
  summarise(Population = sum(population, na.rm = TRUE)) %>%
  ungroup()

# add lga back
delta_itn_clean <- delta_itn_clean %>%
  left_join(delta_itn_data %>%
              dplyr::select(AdminLevel3, AdminLevel2) %>%
              distinct(), by = c("Ward" = "AdminLevel3")) %>% 
  rename(LGA = AdminLevel2)

delta_itn_clean <- delta_itn_clean %>% 
  mutate(Ward = case_when(
    Ward == "Aballa/ Inyi/ Onuaboh" ~	"Aballa/Inyi/Onuaboh",
    Ward == "Abbi 1" ~	"Abbi 8",
    Ward == "Abbi 2" ~	"Abbi 9",
    Ward == "Aboh/ Akarai" ~	"Aboh/Akarai",
    Ward == "Abraka" ~	"Abraka I",
    Ward == "Achalla/Ezukwu/Ogboli" ~	"",
    Ward == "Afor/ Obikwele" ~	"Afor/Obikwele",
    Ward == "Agbarho I" ~	"Agbarho 1",
    Ward == "Agbarho II" ~	"Agbarho 2",
    Ward == "Agbor Obi" ~	"Agbor-Obi 1/Agbor Town II",
    Ward == "Agbor Obi Ward 2" ~	"",
    Ward == "Agbor-Nta" ~	"Agbor-Nta/Agbor Town I",
    Ward == "Agidiasi" ~	"Agiadiasi",
    Ward == "Ajudabo" ~	"Ajudaibo",
    Ward == "Akugbene 3" ~	"Akugbene III",
    Ward == "Akwuebulu" ~	"Akuebolu",
    Ward == "Alihagwu" ~	"Alihagwu/Ihiuiyase I",
    Ward == "Arigborodo" ~	"Abigborodo",
    Ward == "Ashaka/ Ushie" ~	"Ashaka/Ushie",
    Ward == "Boji Boji 1" ~	"Boji-Boji Owa 1/Owa III",
    Ward == "Boji Boji Agbor 1" ~	"Boji-Boji I/ Agbor 7",
    Ward == "Boji Boji Agbor 2" ~	"Boji-Boji II/ Agbor 8",
    Ward == "Boji Boji Owa 2" ~	"Boji-Boji Owa 2/Owa IV",
    Ward == "Egbo" ~	"Egbo/Agbon  VII",
    Ward == "Egini" ~	"Egini/Ovwian II",
    Ward == "Egodor" ~	"",
    Ward == "Ejeme/ Egbudu" ~	"Ejeme/Egbudu",
    Ward == "Ekametagbene/Kalafio" ~	"",
    Ward == "Ekpan I" ~	"Ekpan 9",
    Ward == "Ekpan II" ~	"Ekpan 10",
    Ward == "Eku" ~	"Eku/Agbon  VI",
    Ward == "Enerhen 1" ~	"Enerhen 3",
    Ward == "Enerhen I" ~	"",
    Ward == "Enerhen II" ~	"Enerhen 4",
    Ward == "Ewulu/ Isheagu" ~	"Ewulu/Isheagu",
    Ward == "Ibedeni/ Azagba" ~	"Ibedeni/Azagba",
    Ward == "Iberede/Onu/Iyede-Ame" ~	"Ibrede/Onu/Iyede-Ame",
    Ward == "Idumuje-Umor" ~	"Idumuje-Unor",
    Ward == "Igun" ~	"Igun/Agbon  V",
    Ward == "Irri 1" ~	"Irri 10",
    Ward == "Irri 2" ~	"Irri 11",
    Ward == "Isiokolo" ~	"Isiokolo/Agbon  VIII",
    Ward == "Kokori" ~	"Kokori/Agbon  III",
    Ward == "Mandangho" ~	"Madangho",
    Ward == "Ogbe - Obiaruku" ~	"Ogbeobiaruku",
    Ward == "Ogbe-Udu" ~	"Ogbe Udu",
    Ward == "Ogbudugbudu" ~	"Okbudugbudu",
    Ward == "Ogharefe 1" ~	"Ogharefe 1/Oghara I",
    Ward == "Ogharefe 2" ~	"Ogharefe 2/Oghara II",
    Ward == "Ogharefe 3" ~	"Ogharefe 3/Oghara III",
    Ward == "Oghareki 1" ~	"",
    Ward == "Oghareki 2" ~	"",
    Ward == "Ogor" ~	"",
    Ward == "Ogume 1" ~	"Ogume 6",
    Ward == "Ogume 2" ~	"Ogume 7",
    Ward == "Oko-Ogbele" ~	"Oko Ogbele",
    Ward == "Okpanam/ Ugbolu" ~	"Okpanam/Ugbolu",
    Ward == "Okpara" ~	"Okpara/Agbon  I",
    Ward == "Okuzu" ~	"Okuzu/Obiaruku  II",
    Ward == "Olomu 3" ~	"Olomu 3-Effurun-Otor",
    Ward == "Orhaorpo" ~	"Orhaorpo/Agbon  IV",
    Ward == "Oria" ~	"Oria/Abraka  III",
    Ward == "Orogun I" ~	"Orogun 1",
    Ward == "Orogun II" ~	"Orogun 2-Erhobaro",
    Ward == "Otor-Udu" ~	"Otor Udu/Udu I",
    Ward == "Ovu" ~	"Ovu/Agbon  II",
    Ward == "Owa- Alizomor" ~	"Owa-Alizomor/Owa  VI",
    Ward == "Owa Oyibu" ~	"Owa-Oyibu",
    Ward == "Owa-Alero" ~	"Owa-Alero/Owa II",
    Ward == "Owanta" ~	"Owanta/Owa  V",
    Ward == "Owhe Ward 1" ~	"Owhe 1",
    Ward == "Owhe Ward 2" ~	"Owhe 2",
    Ward == "Owhe Ward 3" ~	"Owhe 3",
    Ward == "Owhrode" ~	"Owhrode/Udu II",
    Ward == "Oyede Ward" ~	"Oyede",
    Ward == "Oyoko" ~	"Oyoko/Abavo I",
    Ward == "Ozanogogo" ~	"Ozanogogo/Ihuozomor (Ozanogogo Alisimie)",
    Ward == "Ozoro Ward 1" ~	"Ozoro 1",
    Ward == "Ozoro Ward 2" ~	"Ozoro 2",
    Ward == "Ozoro Ward 3" ~	"Ozoro 3",
    Ward == "Udomi-Azuowa" ~	"Udomi-Azuowa/Abavo II",
    Ward == "Urhuovie" ~	"Urhuovie/Abraka  II",
    TRUE ~ Ward)) %>% 
  filter(Ward != "(blank)" &
         Ward != "Grand Total" &
         !is.na(Ward) &
         Ward != "") %>% 
  arrange(Ward) %>% 
  dplyr::select(Ward, LGA, Population)

# identify mismatches between cleaned ITN data and extracted data
itn_unique <- unique(delta_itn_clean$Ward)
extracted_unique <- unique(delta_extracted_data$WardName)
missing_in_extracted <- setdiff(itn_unique, extracted_unique)
missing_in_itn <- setdiff(extracted_unique, itn_unique)
cat("Wards in ITN data but not in extracted data:\n")
print(missing_in_extracted)
cat("\nWards in extracted data but not in ITN data:\n")
print(missing_in_itn)

# identify mismatches between cleaned ITN data and shapefile
itn_unique <- unique(delta_itn_clean$Ward)
shapefile_unique <- unique(delta_shapefile$WardName)
missing_in_shapefile <- setdiff(itn_unique, shapefile_unique)
missing_in_itn <- setdiff(shapefile_unique, itn_unique)
cat("Wards in ITN data but not in shapefile:\n")
print(missing_in_shapefile)
cat("\nWards in shapefile but not in ITN data:\n")
print(missing_in_itn)

# save cleaned ITN data
writexl::write_xlsx(delta_itn_clean, file.path(PackageDataDir, "ITN/pbi_distribution_Delta_clean.xlsx"))

# save cleaned shapefile
st_write(delta_shapefile, file.path(PackageDataDir, "shapefiles/Delta/Delta.shp"), delete_layer = TRUE)

## =========================================================================================================================================
### KADUNA
## =========================================================================================================================================

# read in ITN data and extracted data
kaduna_itn_data <- readxl::read_excel(file.path(ITNDir, "pbi_distribution_Kaduna_old.xlsx"))
kaduna_extracted_data <- read.csv(file.path(ExtractedDir, "Kaduna_wards_variables.csv"))
kaduna_shapefile <- st_read(file.path(StateShpDir, "Kaduna/Kaduna_state.shp"))

kaduna_itn_clean <- kaduna_itn_data %>%
  rename(Ward = `AdminLevel3`) %>%
  dplyr::select(population = `N_FamilyMembers`, Ward) %>%
  group_by(Ward) %>%
  summarise(Population = sum(population, na.rm = TRUE)) %>%
  ungroup()

# add lga back
kaduna_itn_clean <- kaduna_itn_clean %>%
  left_join(kaduna_itn_data %>%
              dplyr::select(AdminLevel3, AdminLevel2) %>%
              distinct(), by = c("Ward" = "AdminLevel3")) %>% 
  rename(LGA = AdminLevel2)

kaduna_itn_clean <- kaduna_itn_clean %>% 
  mutate(Ward = case_when(
    Ward == "Awan" ~ "Awon",
    Ward == "Badikko" ~ "Badiko",
    Ward == "Bitaro" ~ "Dura Bitaro",
    Ward == "Budah" ~ "Buda",
    Ward == "D/Abba" ~ "Dutsen Abba",
    Ward == "Dadiriba" ~ "Dadi Riba",
    Ward == "Dammahawayi" ~ "Danmahawayi",
    Ward == "Danalhaji" ~ "Dan Alhaji",
    Ward == "Dandamisa" ~ "Dan Damisa",
    Ward == "Dogon Dawa" ~ "Dogondawa",
    Ward == "Dutse Wai" ~ "Dutsen Wai",
    Ward == "Garu" ~ "Garu 1",
    Ward == "G/Gwanki" ~ "Garu 2",
    Ward == "Garu/Mariri" ~ "Garu Mariri",
    Ward == "Gure/Kahugu" ~ "Gure Kahugu",
    Ward == "Gyallesu" ~ "Gyellesu",
    Ward == "Jama'A" ~ "Jama A",
    Ward == "K/Magani" ~ "Kasuwan Magani",
    Ward == "K/Wali North" ~ "Kauran Wali North",
    Ward == "Kagarko  North" ~ "Kagarko North",
    Ward == "Kagarko  South" ~ "Kagarko South",
    Ward == "Kamanton" ~ "Kamantan",
    Ward == "Kannikon" ~ "Kaninkon",
    Ward == "Karreh" ~ "Kareh",
    Ward == "Kukui" ~ "Kukuyi",
    Ward == "Lazuru/  Tuddai" ~ "Lazuru Tuddai",
    Ward == "Limachin Kona" ~ "Limancin Kona",
    Ward == "Madekiya" ~ "Madakiya",
    Ward == "Maiburji" ~ "Maiburiji",
    Ward == "Mallagum" ~ "Malagum",
    Ward == "Mayere" ~ "Meyari",
    Ward == "Mucha" ~ "Muchiya",
    Ward == "N/Doya" ~ "Nasarawa Wandoya",
    Ward == "Panhuaya" ~ "Panhauya",
    Ward == "Panshanu" ~ "Fanshanu",
    Ward == "Ramin/Kura" ~ "Raminkura",
    Ward == "Sab Chem" ~ "Sabchem",
    Ward == "Sab-Zuro" ~ "Sabzuro",
    Ward == "Sabon Birnin" ~ "Sabon Birnin 1",
    Ward == "Sabonbirni/U/Bawa" ~ "Sabon Birnin 2",
    Ward == "Sabon Gari" ~ "Sabon Garin",
    Ward == "Sam Ban" ~ "Samban",
    Ward == "Saya-Saya" ~ "Saya Saya",
    Ward == "Tantatu" ~ "Tantattu",
    Ward == "U/Dosa" ~ "Unguwan Dosa",
    Ward == "U/Rimi" ~ "Unguwar Rimi",
    Ward == "U/Sanusi" ~ "Unguwan Sanusi",
    Ward == "U/Sarki" ~ "Unguwar Sarki",
    Ward == "U/Shanu" ~ "Unguwar Shanu",
    Ward == "Ung Fatika" ~ "Unguwar Fatika",
    Ward == "Ung Juma" ~ "Unguwar Juma",
    Ward == "Ungwan Gabbas" ~ "Unguwar Gabas",
    Ward == "Ungwar Gaiya" ~ "Unguwar Gaya",
    Ward == "Ungwar Rimi" ~ "Unguwan Rimi",
    Ward == "Zagon Aya" ~ "Zangon Aya",
    Ward == "K/Wali South" ~ "Kauran Wali South",
    Ward == "T/Nupawa" ~ "Tudun Nupawa",
    Ward == "Riga Chikun" ~ "Rigachikun",
    Ward == "Tudun Jukun" ~ "Tukur Tukur",
    Ward == "Doka" & LGA == "Kachia" ~ "Dokwa",
    Ward == "Sabon Garin" & LGA == "Chikun" ~ "Sabon Gari Nassarawa",
    TRUE ~ Ward)) %>% 
  arrange(Ward) %>% 
  dplyr::select(Ward, LGA, Population)

### ALSO CLEAN SHAPEFILE FOR KADUNA ###

# recode WardName in yobe_shp to match the ITN data formatting
kaduna_shapefile <- kaduna_shapefile %>% 
  mutate(WardName = case_when(
    WardName == "Garu" & LGACode == 19016 ~ "Garu 1",
    WardName == "Garu" & LGACode == 19021 ~ "Garu 2",
    WardName == "Sabon Birnin" & WardCode == "KD0410" ~ "Sabon Birnin 1",
    WardName == "Sabon Birnin" & WardCode == "KD1710" ~ "Sabon Birnin 2",
    TRUE ~ WardName
  )) %>% 
  arrange(WardName)

# identify mismatches between cleaned ITN data and extracted data
itn_unique <- unique(kaduna_itn_clean$Ward)
extracted_unique <- unique(kaduna_extracted_data$WardName)
missing_in_extracted <- setdiff(itn_unique, extracted_unique)
missing_in_itn <- setdiff(extracted_unique, itn_unique)
cat("Wards in ITN data but not in extracted data:\n")
print(missing_in_extracted)
cat("\nWards in extracted data but not in ITN data:\n")
print(missing_in_itn)

# identify mismatches between cleaned ITN data and shapefile
itn_unique <- unique(kaduna_itn_clean$Ward)
shapefile_unique <- unique(kaduna_shapefile$WardName)
missing_in_shapefile <- setdiff(itn_unique, shapefile_unique)
missing_in_itn <- setdiff(shapefile_unique, itn_unique)
cat("Wards in ITN data but not in shapefile:\n")
print(missing_in_shapefile)
cat("\nWards in shapefile but not in ITN data:\n")
print(missing_in_itn)

# save cleaned ITN data
writexl::write_xlsx(kaduna_itn_clean, file.path(PackageDataDir, "ITN/pbi_distribution_Kaduna_clean.xlsx"))

# save cleaned shapefile
st_write(kaduna_shapefile, file.path(PackageDataDir, "shapefiles/Kaduna/Kaduna_state.shp"), delete_layer = TRUE)

## =========================================================================================================================================
### NIGER
## =========================================================================================================================================

# read in ITN data and extracted data
niger_itn_data <- read.csv(file.path(ITNDir, "pbi_distribution_Niger.csv"))
niger_extracted_data <- read.csv(file.path(ExtractedDir, "Niger_wards_variables.csv"))
niger_shapefile <- st_read(file.path(StateShpDir, "Niger/Niger_state.shp"))

niger_itn_clean <- niger_itn_data %>%
  rename(population = `N_FamilyMembers`,
         Ward = `AdminLevel3`) %>%
  dplyr::select(population, Ward) %>%
  group_by(Ward) %>%
  summarise(Population = sum(population, na.rm = T)) %>%
  ungroup()

# add lga back
niger_itn_clean <- niger_itn_clean %>%
  left_join(niger_itn_data %>%
              dplyr::select(AdminLevel3, AdminLevel2) %>%
              distinct(), by = c("Ward" = "AdminLevel3")) %>% 
  rename(LGA = AdminLevel2)

niger_itn_clean <- niger_itn_clean %>% 
  mutate(Ward = case_when(
    Ward == "Adunu" ~ "Adono",
    Ward == "Akare" ~ "Akari",
    Ward == "Anaba" ~ "Anaba/Ibelu West",
    Ward == "Badeggi" ~ "Badegi",
    Ward == "Bagama B" ~ "Bagama b",
    Ward == "Bonu" ~ "Bono",
    Ward == "Chanchaga" ~ "Chachanga",
    Ward == "Cheniyan" ~ "Chenian",
    Ward == "Ciki Gari" ~ "Cikin Gari",
    Ward == "Danrangi" ~ "Danragi",
    Ward == "Dokko" ~ "Doko",
    Ward == "Dokodza" ~ "Dokoza",
    Ward == "Ebbo/Gbachinku" ~ "Ebbo",
    Ward == "Ecwa/Gwada" ~ "Egwa/Gwada",
    Ward == "Edozhigi" ~ "Edozigi",
    Ward == "Fahzi" ~ "Fazhi",
    Ward == "Gazhe" ~ "Gazhe 1",
    Ward == "Gupa/Abugi" ~ "Gupa",
    Ward == "Gwarjiko" ~ "Gwarijiko",
    Ward == "Kuchi Bussu" ~ "Kucibusu",
    Ward == "Kura" ~ "Kura/Auna East",
    Ward == "Kurebe/Kushaka" ~ "Kuregbe",
    Ward == "Kuso Tachin" ~ "Kusotacin",
    Ward == "Labohzi" ~ "Labozhi",
    Ward == "Lokogoma" ~ "Lokogwoma",
    Ward == "Magamadaji" ~ "Magamadaji/Ibelu North",
    Ward == "Mantabefyan" ~ "Manbe Tafyan",
    Ward == "Moregi" ~ "Muregi",
    Ward == "Muye" ~ "Muye/Egba",
    Ward == "Busuru" ~ "Bunsuru",
    Ward == "Dan Dauda" ~ "Dandaudu",
    Ward == "Dasun" ~ "Dassun",
    Ward == "Gusoro/Zumba" ~ "Gussoro/Zumba",
    Ward == "Iku 1" ~ "Iku 1/Iku South I",
    Ward == "Iku 2" ~ "Iku 2/Iku South II",
    Ward == "Kafinkoro" ~ "Kafin Koro",
    Ward == "Kawna (Tegina West)" ~ "Tegina West",
    Ward == "Kucibusu" ~ "Kuchi Bussu",
    Ward == "Kundu (Gunna South)" ~ "Gunna South",
    Ward == "Kuregbe" ~ "Kurebe/Kushaka",
    Ward == "Kusheriki North" ~ "Kusherki North",
    Ward == "Kusheriki South" ~ "Kusherki South",
    Ward == "Kusotacin" ~ "Kuso Tachin",
    Ward == "Kwaki" ~ "Kwaki/Chikuba",
    Ward == "Madaka (Kakuri)" ~ "Kakuri",
    Ward == "Maikujeri (Kongoma West)" ~ "Kongoma West",
    Ward == "Manigi" ~ "Manigi/Dapangi/Makera",
    Ward == "Masaba A" ~ "Masaba A/Masaga I",
    Ward == "Masaga B" ~ "Masaga B/Masaga  II",
    Ward == "Muregi" ~ "Moregi",
    Ward == "Muye/Egba" ~ "Muye",
    Ward == "Nikuchi Tunga Mallam" ~ "Tungamallam/Nikuchi",
    Ward == "Nuwankota" ~ "Nuwan Kuta",
    Ward == "Pina" ~ "Pina/Kolu",
    Ward == "Rabba Ndayoko" ~ "Raba Ndayako",
    Ward == "Sabon Gari Ushe" ~ "Sabon Gari Wuse",
    Ward == "Sahonrami" ~ "Sahonrami/Saho-Rami",
    Ward == "Salka" ~ "Salka/Auna East Central",
    Ward == "Sarkin Pawa" ~ "Sarki Power",
    Ward == "Sommazhiko" ~ "Sojmajiko",
    Ward == "T/Wada North" ~ "T/Wada N",
    Ward == "T/Wada South" ~ "T/Wada S",
    Ward == "Tungan Jika" ~ "Tungajika/Auna South",
    Ward == "Umaru Majlgi A" ~ "Umaru Majagi A/Umaru Majigi  I",
    Ward == "Umaru Majlgi B" ~ "Umaru Majagi B/Umaru Majigi  II",
    Ward == "Yangalu" ~ "Yangalu/Ibelu East",
    Ward == "Yekila(Gunna)" ~ "Gunna Central",
    Ward == "Kafinkoro" ~ "Kafin Koro",
    TRUE ~ Ward)) %>% 
  arrange(Ward) %>% 
  dplyr::select(Ward, LGA, Population)

# identify mismatches
itn_unique <- unique(niger_itn_clean$Ward)
extracted_unique <- unique(niger_extracted_data$WardName)
missing_in_extracted <- setdiff(itn_unique, extracted_unique)
missing_in_itn <- setdiff(extracted_unique, itn_unique)
cat("Wards in ITN data but not in extracted data:\n")
print(missing_in_extracted)
cat("\nWards in extracted data but not in ITN data:\n")
print(missing_in_itn)

# identify mismatches between cleaned ITN data and shapefile
itn_unique <- unique(niger_itn_clean$Ward)
shapefile_unique <- unique(niger_shapefile$WardName)
missing_in_shapefile <- setdiff(itn_unique, shapefile_unique)
missing_in_itn <- setdiff(shapefile_unique, itn_unique)
cat("Wards in ITN data but not in shapefile:\n")
print(missing_in_shapefile)
cat("\nWards in shapefile but not in ITN data:\n")
print(missing_in_itn)

# save cleaned ITN data
writexl::write_xlsx(niger_itn_clean, file.path(PackageDataDir, "ITN/pbi_distribution_Niger_clean.xlsx"))

# save cleaned shapefile
st_write(niger_shapefile, file.path(PackageDataDir, "shapefiles/Niger/Niger.shp"), delete_layer = TRUE)

## =========================================================================================================================================
### TARABA
## =========================================================================================================================================

# read in ITN data and extracted data
taraba_itn_data <- readxl::read_excel(file.path(ITNDir, "original full ITN datasets/pbi_distribution_Taraba.xlsx"))
taraba_extracted_data <- read.csv(file.path(ExtractedDir, "Taraba_wards_variables.csv"))

# clean ITN data
taraba_itn_clean <- taraba_itn_data %>%
  rename(Ward = `AdminLevel3`, population = `N_FamilyMembers`) %>%
  dplyr::select(Ward, population) %>%
  group_by(Ward) %>%
  summarise(Population = sum(population, na.rm = TRUE))

# add lga back
taraba_itn_clean <- taraba_itn_clean %>%
  left_join(taraba_itn_data %>%
              dplyr::select(AdminLevel3, AdminLevel2) %>%
              distinct(), by = c("Ward" = "AdminLevel3")) %>% 
  rename(LGA = AdminLevel2)

taraba_itn_clean <- taraba_itn_clean %>% 
  mutate(Ward = case_when(
    Ward == "Dampar I" ~ "Dampar 1",
    Ward == "Dampar II" ~ "Dampar 2",
    Ward == "Dampar III" ~ "Dampar 3",
    Ward == "Lissam I" ~ "Lissam 1",
    Ward == "Lissam Ii" ~ "Lissam 2",
    Ward == "Nwonyo I" ~ "Nwonyo 1",
    Ward == "Nwonyo II" ~ "Nwonyo 2",
    Ward == "Rimi Uku I" ~ "Rimi Uku 1",
    Ward == "Rimi Uku II" ~ "Rimi Uku 2",
    Ward == "Sarkin Kudu I" ~ "Sarkin Kudu 1",
    Ward == "Sarkin Kudu II" ~ "Sarkin Kudu 2",
    Ward == "Sarkin Kudu III" ~ "Sarkin Kudu 3",
    Ward == "Kussum Badakoshi" ~ "Kussum/Badakoshi",
    Ward == "Panti-Sawa" ~ "Pantisawa",
    Ward == "Zangonkombi" ~ "Zangon Kombi",
    Ward == "Kassala-Sembe" ~ "Kachala-Sembe",
    Ward == "Kpambo Purfi" ~ "Kpambo Puri",
    Ward == "Kotsensi" ~ "Kosensi",
    Ward == "Mbamaga" ~ "Mbamnga",
    Ward == "Gangdole" ~ "Gang Dole",
    Ward == "Ganglari" ~ "Gang Lari",
    Ward == "Gangmata" ~ "Gang Mata",
    Ward == "Gangtiba" ~ "Gang Tiba",
    Ward == "Jenkaigama" ~ "Jen Kaigama",
    Ward == "Wurojam" ~ "Wuro Jam",
    Ward == "Danadda" ~ "Donadda",
    Ward == "Kpambo" ~ "Kpambo 1",
    Ward == "Gongon" ~ "Gongong",
    Ward == "Manang" ~ "Mannang",
    Ward == "Lama" ~ "Lamma",
    Ward == "Maidanu" ~ "Mai Idanu",
    Ward == "Majindadi" ~ "Majidadi",
    TRUE ~ Ward)) %>%
  filter(Ward != "(blank)" &
           Ward != "Grand Total" &
           !is.na(Ward) &
           Ward != "") %>% 
  arrange(Ward) %>% 
  dplyr::select(Ward, LGA, Population)

### ALSO CLEAN SHAPEFILE FOR TARABA ###
TarabaDir <- file.path("/Users/grace/Urban Malaria Proj Dropbox/urban_malaria/data/nigeria/NMEP_nigeria_shapefiles/states/Taraba")
taraba_shp <- read_sf(file.path(TarabaDir, "Taraba.shp")) %>% 
  arrange(WardName)

# recode WardName in taraba_shp to match the ITN data formatting
taraba_shp$WardName <- dplyr::recode(taraba_shp$WardName,
                                     "Dampar I" = "Dampar 1",
                                     "Dampar II" = "Dampar 2",
                                     "Dampar III" = "Dampar 3",
                                     "Gongon" = "Gongong")


# identify mismatches between cleaned ITN data and extracted data
itn_unique <- unique(taraba_itn_clean$Ward)
extracted_unique <- unique(taraba_extracted_data$WardName)
missing_in_extracted <- setdiff(itn_unique, extracted_unique)
missing_in_itn <- setdiff(extracted_unique, itn_unique)
cat("Wards in ITN data but not in extracted data:\n")
print(missing_in_extracted)
cat("\nWards in extracted data but not in ITN data:\n")
print(missing_in_itn)

# identify mismatches between cleaned ITN data and shapefile
itn_unique <- unique(taraba_itn_clean$Ward)
shapefile_unique <- unique(taraba_shp$WardName)
missing_in_shapefile <- setdiff(itn_unique, shapefile_unique)
missing_in_itn <- setdiff(shapefile_unique, itn_unique)
cat("Wards in ITN data but not in shapefile:\n")
print(missing_in_shapefile)
cat("\nWards in shapefile but not in ITN data:\n")
print(missing_in_itn)

# save cleaned ITN data
writexl::write_xlsx(taraba_itn_clean, file.path(PackageDataDir, "ITN/pbi_distribution_Taraba_clean.xlsx"))

# save cleaned shapefile
st_write(taraba_shp, file.path(PackageDataDir, "shapefiles/Taraba/Taraba.shp"), delete_layer = TRUE)

## =========================================================================================================================================
### YOBE
## =========================================================================================================================================

# read in ITN data and extracted data
yobe_itn_data <- readxl::read_excel(file.path(ITNDir, "pbi_distribution_Yobe.xlsx"))
yobe_extracted_data <- read.csv(file.path(ExtractedDir, "Yobe_wards_variables.csv"))
yobe_shp <- st_read(file.path(PackageDataDir, "shapefiles/Yobe/Yobe_state.shp"))

yobe_itn_clean <- yobe_itn_data %>%
  rename(population = `N_FamilyMembers`,
         Ward = `AdminLevel3`,
         LGA = AdminLevel2) %>%
  dplyr::select(population, Ward, LGA) %>%
  group_by(Ward) %>%
  summarise(Population = sum(population, na.rm = T)) %>%
  ungroup()

# add lga back
yobe_itn_clean <- yobe_itn_clean %>%
  left_join(yobe_itn_data %>%
              dplyr::select(AdminLevel3, AdminLevel2) %>%
              distinct(), by = c("Ward" = "AdminLevel3")) %>% 
  rename(LGA = AdminLevel2)

yobe_itn_clean <- yobe_itn_clean %>% 
  mutate(Ward = case_when(
    Ward == "Asheikiri" ~ "Asheikri",
    Ward == "Balanguwa" ~ "Bulanguwa",
    Ward == "Bare-Bari" ~ "Bare Bari",
    Ward == "Chikuiwa" ~ "Chukuriwa",
    Ward == "Chilariya" ~ "Chillariye",
    Ward == "Danani/Lawanti" ~ "Danani Lawanti",
    Ward == "Darin/Lang" ~ "Darin Langawa",
    Ward == "Dogo Nini" ~ "Dogon Nini",
    Ward == "Dole Machina" ~ "Dole",
    Ward == "Faji Ganari" ~ "Fajiganari",
    Ward == "Falimiram" ~ "Falimaram",
    Ward == "Fika/Anze" ~ "Fika Anze",
    Ward == "Gadaka/Shembire" ~ "Gadaka/She",
    Ward == "Goniri" ~ "Goneri",
    Ward == "Gotala" ~ "Gotala Gotumba",
    Ward == "Guba/Dapso" ~ "Guba Dapso",
    Ward == "Guji/Metalari" ~ "Guji Metalari",
    Ward == "Hausawa Asibity" ~ "Hausawa Asibiti",
    Ward == "Jajimaji" ~ "Jaji Maji",
    Ward == "Jawa/Garun Dole" ~ "Jawa Garun Dole",
    Ward == "Julluri" ~ "Juluri Damnawa",
    Ward == "Karasuwa Garin Guna" ~ "Karausuwa Garin Guna",
    Ward == "Koka/Sungul" ~ "Sungul Koka",
    Ward == "Kollere PHCC" ~ "Kollere Kafaje",
    Ward == "Konkonmma" ~ "Konkomma",
    Ward == "Koryel" ~ "Koriyel",
    Ward == "Kumagannam" ~ "Kumaganam",
    Ward == "Lantaiwa" ~ "Lantewa",
    Ward == "Ma'Anna" ~ "Ma'anna",
    Ward == "Maisandari Waziri Ibrahim" ~ "Maisandari/Waziri Ibrahim",
    Ward == "Majakura" ~ "Maja Kura",
    Ward == "Mari-Mari/Gud" ~ "Marmari Gudugurka",
    Ward == "Mazagon" ~ "Mozogun",
    Ward == "Moyori" ~ "Mayori",
    Ward == "Murfa Kalam" ~ "Murfakalam",
    Ward == "Ngalda/Dumbulwa" ~ "Ngalda/Dumb",
    Ward == "Njiwaji Gwange" ~ "Njiwaji/Gwange",
    Ward == "Sabon Gari Kanuri" ~ "S G Kanuri",
    Ward == "Sabongari" ~ "Sabon Gari",
    Ward == "Sasawa Kabaru" ~ "Sasawa/Kabaru",
    Ward == "Shoye/Garin Aba" ~ "Shoye",
    Ward == "Turmi/Maluri" ~ "Turmi Malori",
    Ward == "Yarimaram" ~ "Yerimaram",
    Ward == "Zangaya/Mazawun" ~ "Zangaya Mazawaun",
    TRUE ~ Ward)) %>% 
  arrange(Ward) %>% 
  dplyr::select(Ward, LGA, Population)

### ALSO CLEAN SHAPEFILE FOR YOBE ###
yobe_shp <- read_sf(file.path(DataDir, "nigeria/NMEP_nigeria_shapefiles/states/Yobe/Yobe.shp")) %>% 
  arrange(WardName)

# recode WardName in yobe_shp to match the ITN data formatting
yobe_shp$WardName <- dplyr::recode(yobe_shp$WardName,
                                   "Bare-Bari" = "Bare Bari",
                                   "Chilariya" = "Chillariye",
                                   "Chikuiwa" = "Chukuriwa",
                                   "Danani/Lawanti" = "Danani Lawanti",
                                   "Darin/Lang" = "Darin Langawa",
                                   "Dogo Nini" = "Dogon Nini",
                                   "Dole Machina" = "Dole",
                                   "Faji Ganari" = "Fajiganari",
                                   "Falimiram" = "Falimaram",
                                   "Fika/Anze" = "Fika Anze",
                                   "Gadaka/Shembire" = "Gadaka/She",
                                   "Goniri" = "Goneri",
                                   "Gotala" = "Gotala Gotumba",
                                   "Guji/Metalari" = "Guji Metalari",
                                   "Hausawa Asibity" = "Hausawa Asibiti",
                                   "Jajimaji" = "Jaji Maji",
                                   "Jawa/Garun Dole" = "Jawa Garun Dole",
                                   "Julluri" = "Juluri Damnawa",
                                   "Karasuwa Garin Guna" = "Karausuwa Garin Guna",
                                   "Kollere PHCC" = "Kollere Kafaje",
                                   "Koryel" = "Koriyel",
                                   "Lantaiwa" = "Lantewa",
                                   "Ma'Anna" = "Ma'anna",
                                   "Maisandari Waziri Ibrahim" = "Maisandari/Waziri Ibrahim",
                                   "Majakura" = "Maja Kura",
                                   "Mari-Mari/Gud" = "Marmari Gudugurka",
                                   "Moyori" = "Mayori",
                                   "Mazagon" = "Mozogun",
                                   "Murfa Kalam" = "Murfakalam",
                                   "Ngalda/Dumbulwa" = "Ngalda/Dumb",
                                   "Njiwaji Gwange" = "Njiwaji/Gwange",
                                   "Sabon Gari Kanuri" = "S G Kanuri",
                                   "Sabongari" = "Sabon Gari",
                                   "Shoye/Garin Aba" = "Shoye",
                                   "Koka/Sungul" = "Sungul Koka",
                                   "Turmi/Maluri" = "Turmi Malori",
                                   "Yarimaram" = "Yerimaram",
                                   "Zangaya/Mazawun" = "Zangaya Mazawaun")

# identify mismatches between cleaned ITN data and extracted data
itn_unique <- unique(yobe_itn_clean$Ward)
extracted_unique <- unique(yobe_extracted_data$WardName)
missing_in_extracted <- setdiff(itn_unique, extracted_unique)
missing_in_itn <- setdiff(extracted_unique, itn_unique)
cat("Wards in ITN data but not in extracted data:\n")
print(missing_in_extracted)
cat("\nWards in extracted data but not in ITN data:\n")
print(missing_in_itn)

# identify mismatches between cleaned ITN data and shapefile
itn_unique <- unique(yobe_itn_clean$Ward)
shapefile_unique <- unique(yobe_shp$WardName)
missing_in_shapefile <- setdiff(itn_unique, shapefile_unique)
missing_in_itn <- setdiff(shapefile_unique, itn_unique)
cat("Wards in ITN data but not in shapefile:\n")
print(missing_in_shapefile)
cat("\nWards in shapefile but not in ITN data:\n")
print(missing_in_itn)

# save cleaned ITN data
writexl::write_xlsx(yobe_itn_clean, file.path(PackageDataDir, "ITN/pbi_distribution_Yobe_clean.xlsx"))

# save cleaned shapefile
st_write(yobe_shp, file.path(PackageDataDir, "shapefiles/Yobe/Yobe.shp"), delete_layer = TRUE)



## =========================================================================================================================================
### ALL STATES SHAPEFILE (by Hephzibah) — use to check on the remaining mismatched wards
## =========================================================================================================================================

source("add_lga_ward.R")

all_shp <- st_read(file.path("/Users/grace/Urban Malaria Proj Dropbox/urban_malaria/data/nigeria/NMEP_nigeria_shapefiles/complete_names_wards/wards.shp"))

all_shp <- all_shp %>%
  group_by(StateCode) %>%
  arrange(StateCode, WardName, .by_group = TRUE) %>%
  ungroup() %>% 
  dplyr::filter(StateCode %in% c("DE", "TA", "YO", "KD", "KT", "NI"))

# make state shapefiles that include LGA
delta_lgas <- st_drop_geometry(all_shp %>% dplyr::filter(StateCode == "DE") %>% dplyr::select(WardCode, WardName, LGAName))
taraba_lgas <- st_drop_geometry(all_shp %>% dplyr::filter(StateCode == "TA") %>% dplyr::select(WardCode, WardName, LGAName))
yobe_lgas <- st_drop_geometry(all_shp %>% dplyr::filter(StateCode == "YO") %>% dplyr::select(WardCode, WardName, LGAName))
kaduna_lgas <- st_drop_geometry(all_shp %>% dplyr::filter(StateCode == "KD") %>% dplyr::select(WardCode, WardName, LGAName))
katsina_lgas <- st_drop_geometry(all_shp %>% dplyr::filter(StateCode == "KT") %>% dplyr::select(WardCode, WardName, LGAName))
niger_lgas <- st_drop_geometry(all_shp %>% dplyr::filter(StateCode == "NI") %>% dplyr::select(WardCode, WardName, LGAName))

# read in cleaned shapefiles and add LGA names to each
delta_shp <- st_read(file.path(PackageDataDir, "shapefiles/Delta/Delta.shp")) 
taraba_shp <- st_read(file.path(PackageDataDir, "shapefiles/Taraba/Taraba.shp"))
yobe_shp <- st_read(file.path(PackageDataDir, "shapefiles/Yobe/Yobe.shp"))
kaduna_shp <- st_read(file.path(PackageDataDir, "shapefiles/Kaduna/Kaduna.shp"))
katsina_shp <- st_read(file.path(PackageDataDir, "shapefiles/Katsina/Katsina.shp"))
niger_shp <- st_read(file.path(PackageDataDir, "shapefiles/Niger/Niger.shp"))

# add LGA names to shapefiles and lists with LGAs
delta_shp <- clean_shapefile(state_name = "Delta", delta_shp)
taraba_shp <- clean_shapefile(state_name = "Taraba", taraba_shp)
yobe_shp <- clean_shapefile(state_name = "Yobe", yobe_shp)
kaduna_shp <- clean_shapefile(state_name = "Kaduna", kaduna_shp)
katsina_shp <- clean_shapefile(state_name = "Katsina", katsina_shp)
niger_shp <- clean_shapefile(state_name = "Niger", niger_shp)


delta_shp <- delta_shp %>% left_join(delta_lgas, by = c("WardCode")) %>% dplyr::select(-WardName.y) %>% rename(WardName = WardName.x) %>% arrange(WardName)
taraba_shp <- taraba_shp %>% left_join(taraba_lgas, by = c("WardCode")) %>% dplyr::select(-WardName.y) %>% rename(WardName = WardName.x) %>% arrange(WardName)
yobe_shp <- yobe_shp %>% left_join(yobe_lgas, by = c("WardCode")) %>% dplyr::select(-WardName.y) %>% rename(WardName = WardName.x) %>% arrange(WardName)
kaduna_shp <- kaduna_shp %>% left_join(kaduna_lgas, by = c("WardCode")) %>% dplyr::select(-WardName.y) %>% rename(WardName = WardName.x) %>% arrange(WardName)
katsina_shp <- katsina_shp %>% left_join(katsina_lgas, by = c("WardCode")) %>% dplyr::select(-WardName.y) %>% rename(WardName = WardName.x) %>% arrange(WardName)
niger_shp <- niger_shp %>% left_join(niger_lgas, by = c("WardCode")) %>% dplyr::select(-WardName.y) %>% rename(WardName = WardName.x) %>% arrange(WardName)

# save all cleaned shapefile (now with LGAs!)
st_write(delta_shp, file.path(PackageDataDir, "shapefiles/Delta/Delta.shp"), delete_layer = TRUE)
st_write(taraba_shp, file.path(PackageDataDir, "shapefiles/Taraba/Taraba.shp"), delete_layer = TRUE)
st_write(yobe_shp, file.path(PackageDataDir, "shapefiles/Yobe/Yobe.shp"), delete_layer = TRUE)
st_write(kaduna_shp, file.path(PackageDataDir, "shapefiles/Kaduna/Kaduna.shp"), delete_layer = TRUE)
st_write(katsina_shp, file.path(PackageDataDir, "shapefiles/Katsina/Katsina.shp"), delete_layer = TRUE)
st_write(niger_shp, file.path(PackageDataDir, "shapefiles/Niger/Niger.shp"), delete_layer = TRUE)


## =========================================================================================================================================
### Add LGA names to duplicate wards in the ITN data
## =========================================================================================================================================

# read in ITN data for all states
delta_itn <- read_excel(file.path(PackageDataDir, "ITN/pbi_distribution_Katsina_clean.xlsx")) 
taraba_itn <- read_excel(file.path(PackageDataDir, "ITN/pbi_distribution_Taraba_clean.xlsx")) 
yobe_itn <- read_excel(file.path(PackageDataDir, "ITN/pbi_distribution_Yobe_clean.xlsx")) 
kaduna_itn <- read_excel(file.path(PackageDataDir, "ITN/pbi_distribution_Kaduna_clean.xlsx")) 
katsina_itn <- read_excel(file.path(PackageDataDir, "ITN/pbi_distribution_Katsina_clean.xlsx")) 
niger_itn <- read_excel(file.path(PackageDataDir, "ITN/pbi_distribution_Niger_clean.xlsx")) 

# add LGA names to itn data wards
delta_itn <- clean_itn_data(state_name = "Delta", delta_itn)
taraba_itn <- clean_itn_data(state_name = "Taraba", taraba_itn)
yobe_itn <- clean_itn_data(state_name = "Yobe", yobe_itn)
kaduna_itn <- clean_itn_data(state_name = "Kaduna", kaduna_itn)
katsina_itn <- clean_itn_data(state_name = "Katsina", katsina_itn)
niger_itn <- clean_itn_data(state_name = "Niger", niger_itn)

# save cleaned ITN data for all states
writexl::write_xlsx(delta_itn, file.path(PackageDataDir, "ITN/pbi_distribution_Delta_clean.xlsx"))
writexl::write_xlsx(taraba_itn, file.path(PackageDataDir, "ITN/pbi_distribution_Taraba_clean.xlsx"))
writexl::write_xlsx(yobe_itn, file.path(PackageDataDir, "ITN/pbi_distribution_Yobe_clean.xlsx"))
writexl::write_xlsx(kaduna_itn, file.path(PackageDataDir, "ITN/pbi_distribution_Kaduna_clean.xlsx"))
writexl::write_xlsx(katsina_itn, file.path(PackageDataDir, "ITN/pbi_distribution_Katsina_clean.xlsx"))
writexl::write_xlsx(niger_itn, file.path(PackageDataDir, "ITN/pbi_distribution_Niger_clean.xlsx"))
