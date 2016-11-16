# Hitobito Pro Natura

This hitobito wagon defines the organization hierarchy with groups and roles
of Pro Natura.


## Organization Hierarchy

* Dachverband
  * Dachverband
    * PL Jugend: [:layer_and_below_full, :admin, :contact_data]
  * Gremium
    * Leiter/in: [:layer_and_below_read, :group_and_below_full, :contact_data]
    * Mitglied: [:layer_read, :contact_data]
* Sektion
  * Sektion
    * Sektionsverwaltung: [:layer_and_below_full, :contact_data]
* Jugendgruppe
  * Jugendgruppe
    * Leiter/in: [:layer_and_below_read, :contact_data]
    * Aktivmitglied: []
    * Verantwortliche/r: [:layer_and_below_full, :contact_data]
  * Gremium
    * Leiter/in: [:group_and_below_full]
    * Mitglied: [:group_and_below_read]
  * Externe/Helfer/Passivmitglieder
    * Adressverwaltung: [:group_and_below_full]
    * Passivmitglied/Extern/Hilfsperson: []


(Output of rake app:hitobito:roles)
