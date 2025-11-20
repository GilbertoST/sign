"""
Script de migration pour renforcer les champs de consentement RGPD.
- Ajoute les colonnes de timestamp
- Réinitialise les consentements existants (à renouveler explicitement)
"""
from sqlalchemy import text
from database import SessionLocal


def upgrade():
    db = SessionLocal()
    try:
        print("Migration RGPD : mise à jour des consentements")

        columns = {
            row[1] for row in db.execute(text("PRAGMA table_info(users)")).fetchall()
        }

        # Ajouter les colonnes de timestamps si elles n'existent pas déjà
        if "gdpr_consent_at" not in columns:
            db.execute(text("ALTER TABLE users ADD COLUMN gdpr_consent_at DATETIME"))
            print("✓ Colonne gdpr_consent_at ajoutée")
        else:
            print("• Colonne gdpr_consent_at déjà présente, étape ignorée")

        if "data_processing_consent_at" not in columns:
            db.execute(text("ALTER TABLE users ADD COLUMN data_processing_consent_at DATETIME"))
            print("✓ Colonne data_processing_consent_at ajoutée")
        else:
            print("• Colonne data_processing_consent_at déjà présente, étape ignorée")

        # Réinitialiser les consentements existants pour exiger une reconfirmation explicite
        db.execute(
            text(
                """
                UPDATE users
                SET gdpr_consent = 0,
                    data_processing_consent = 0,
                    gdpr_consent_at = NULL,
                    data_processing_consent_at = NULL
                """
            )
        )
        db.commit()
        print("✓ Consentements existants réinitialisés")
        print("✅ Migration terminée - pensez à redemander le consentement aux utilisateurs.")
    except Exception as exc:
        db.rollback()
        print(f"❌ Erreur lors de la migration : {exc}")
    finally:
        db.close()


if __name__ == "__main__":
    upgrade()

