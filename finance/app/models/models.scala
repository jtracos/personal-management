package models

import java.time.LocalDate

case class OutcomesInformation(
                                userId: Long,
                                outcomeId: Int,
                                recurrence: Int,
                                amount: BigDecimal,
                                updateDate: LocalDate,
                                startDate: Option[LocalDate],
                                endDate: Option[LocalDate],
                                paymentDay:Option[Int],
                                isPeriodic: Boolean,
                                outcomeDesc: String
                              )

case class Outcomes(
                     userId: Long,
                     outcomeId: Int,
                     cardTypeId: Int,
                     bankId: Int,
                     update_date: LocalDate
                   )

case class Recurrences(
                         recurrenceId: Int,
                         recurrence_desc: String,
                         updateDate: LocalDate)

case class EntityInformation(
                            EntityId: Int,
                            EntityDesc: String
)

case class CardTypes(
                      cardTypeId: Int,
                      cardTypeDesc: String
                    )

case class PaymentInformation(
                               userId: Long,
                               bankId: Int,
                               cardTypeId: Int,
                               paymentLimitDay: Option[Int],
                               paymentLapse: Option[Int],
                               updateDate: LocalDate
                             )
case class Users(
                  userId: Long,
                  userName: String,
                  firstName: Option[String],
                  lastName: Option[String],
                  birthDate: LocalDate,
                  signUpDate: LocalDate,
                  isActive: Boolean,
                  updateDate: Option[LocalDate]
                 )

case class User(
                  name: String,
                  birthDate: LocalDate,
                  signUpDate: LocalDate,
                  isActive: Boolean,
                  updateDate: Option[LocalDate]
                )
object User{
  def from(user: Users):User =
    User(user.userName + " " + user.firstName.getOrElse("") + " " + user.lastName.getOrElse(""),
      user.birthDate, user.signUpDate, user.isActive, user.updateDate)
}
