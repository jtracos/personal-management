package controllers

import play.api.data.Form
import play.api.data.Forms._
import java.time.LocalDate

object userForm {

  case class NewUser(name:String, firstName:String, lastName:String, birthDate:LocalDate)

  val userForm: Form[NewUser] = Form(
    mapping(
      "name" -> text(),
      "apPaterno" -> text(),
      "apMaterno" -> text(),
      "bornDate" -> localDate("YYYY-MM-DD")
    )(NewUser.apply)(NewUser.unapply)
  )
}
