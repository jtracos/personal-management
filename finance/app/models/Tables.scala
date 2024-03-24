package models

import slick.jdbc.MySQLProfile.api._

import java.time.LocalDate
object definitions {
  lazy val paymentInformationTable = TableQuery[PaymentInformationTable]
  lazy val cardTypesTable = TableQuery[CardTypesTable]
  lazy val entityInfoTable = TableQuery[EntityInfoTable]
  lazy val recurrencesTable = TableQuery[RecurrencesTable]
  lazy val outcomesTable = TableQuery[OutcomesTable]
  lazy  val outcomesInformationTable = TableQuery[OutcomesInformationTable]
  lazy val usersTable = TableQuery[UsersTable]

  class OutcomesInformationTable(tag: Tag) extends  Table[OutcomesInformation](tag, "OUTCOMES_INFORMATION"){
    def userId = column[Long]("USER_ID")
    def outcomeId = column[Int]("OUTCOME_ID")
    def recurrence = column[Int]("RECURRENCE_ID", O.Default(-1))
    def amount = column[BigDecimal]("AMOUNT")
    def updateDate =  column[LocalDate]("UPDATE_DATE")
    def startDate =  column[Option[LocalDate]]("START_DATE")
    def endDate =  column[Option[LocalDate]]("END_DATE")
    def paymentDay = column[Option[Int]]("PAYMENT_DAY")
    def isPeriodic = column[Boolean]("IS_PERIODIC")
    def outcomeDesc = column[String]("OUTCOMES_DESC", O.SqlType("VARCHAR(50)"))

    def * = (userId, outcomeId, recurrence, amount, updateDate, startDate, endDate, paymentDay, isPeriodic, outcomeDesc) <>
      (OutcomesInformation.tupled, OutcomesInformation.unapply _)

    def recurrenceFK = foreignKey("FK_OUTCOMES_RECURRENCE", recurrence, recurrencesTable)(_.id)
    def outInfoPK = primaryKey("PK_OUTCOMES_INFO", (userId, outcomeId, updateDate))
  }
  class OutcomesTable(tag:Tag) extends  Table[Outcomes](tag, "OUTCOMES"){
    def userId = column[Long]("USER_ID")
    def outcomeId = column[Int]("OUTCOME_ID")
    def cardTypeId = column[Int]("CARD_TYPE_ID")
    def bankId = column[Int]("BANK_ID")
    def updateDate = column[LocalDate]("UPDATE_DATE")

    def * = (userId, outcomeId, cardTypeId, bankId, updateDate) <> (Outcomes.tupled, Outcomes.unapply _)

    def userFK = foreignKey("FK_OUTCOMES_USER", userId, usersTable)(_.userId)
    def outcomesInfoFK = foreignKey("FK_OUTCOMES_INFO",(userId, outcomeId), outcomesInformationTable)(
      e => (e.userId, e.outcomeId))
    def paymentInfoPK =
      foreignKey("FK_OUTCOMES_PAYMENT",(userId,bankId, cardTypeId), paymentInformationTable)(
        e => (e.userId, e.bankId, e.cardTypeId))
  }
  class PaymentInformationTable(tag: Tag)
    extends Table[PaymentInformation](tag, "PAYMENT_INFORMATION") {
    def userId = column[Long]("USER_ID")

    def bankId = column[Int]("BANK_ID")

    def cardTypeId = column[Int]("CARD_TYPE_ID")

    def paymentLimitDay = column[Option[Int]]("CARD_TYPE_ID")

    def paymentLapse = column[Option[Int]]("PAYMENT_LAPSE")

    def updateDate = column[LocalDate]("UPDATE_DATE")

    def * = {
      (userId, bankId, cardTypeId, paymentLimitDay, paymentLapse, updateDate) <> (PaymentInformation.tupled, PaymentInformation.unapply _)
    }
    def entityInformationPK = primaryKey("PK_PAYMENTS",(bankId, userId, cardTypeId))
    def cardTypeFK = foreignKey("FK_CARD_TYPE", cardTypeId, cardTypesTable)(_.id)
    def entityFK = foreignKey("FK_BANK", cardTypeId, entityInfoTable)(_.id)
    def userPK = foreignKey("FK_USER", userId, usersTable)(_.userId)
  }

  class UsersTable(tag:Tag) extends Table[Users](tag, "USERS"){
    def userId = column[Long]("USER_ID")
    def userName = column[String]("USER_NAME", O.SqlType("VARCHAR(50)"))
    def firstName = column[Option[String]]("FIRST_NAME", O.SqlType("VARCHAR(50)"))
    def lastName = column[Option[String]]("LAST_NAME", O.SqlType("VARCHAR(50)"))
    def birthDate =  column[LocalDate]("BIRTH_DATE")
    def signUpDate =  column[LocalDate]("SIGNUP_DATE")
    def isActive = column[Boolean]("IS_ACTIVE")
    def updateDate = column[Option[LocalDate]]("UPDATE_DATE")
    def * = (userId, userName, firstName, lastName, birthDate, signUpDate, isActive, updateDate) <> (Users.tupled, Users.unapply _)
    def userPK = primaryKey("PK_USER", userId)
  }

  class CardTypesTable(tag: Tag)
    extends Table[CardTypes](tag, "CARD_TYPES") {

    def id = column[Int]("CARD_TYPE_ID", O.PrimaryKey)

    def description = column[String]("CARD_TYPE_DESC", O.SqlType("VARCHAR(50)"))

    def * = {
      (id, description) <> (CardTypes.tupled, CardTypes.unapply _)
    }

    def productPricePK = primaryKey("PK_CARD_TYPE", id)
  }

  class EntityInfoTable(tag: Tag)
    extends Table[EntityInformation](tag, "BANK_INFORMATION") {

    def id = column[Int]("BANK_ID", O.PrimaryKey)

    def description = column[String]("BANK_DESC", O.SqlType("VARCHAR(50)"))

    def * = {
      (id, description) <> (EntityInformation.tupled, EntityInformation.unapply _)
    }

    def productPricePK = primaryKey("PK_BANK", id)
  }

  class RecurrencesTable(tag:Tag) extends Table[Recurrences](tag, "RECURRENCES"){
    def id = column[Int]("RECURRENCE_ID", O.PrimaryKey)
    def description = column[String]("RECURRENCE_DESC", O.SqlType("VARCHAR(50)"))
    def updateDate = column[LocalDate]("UPDATE_DATE")
    def * =
      (id, description, updateDate) <> (Recurrences.tupled, Recurrences.unapply _)
  }
}