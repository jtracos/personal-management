package controllers

import javax.inject._
import play.api._
import play.api.data.Form
import play.api.data.Forms._
import play.api.mvc._
import dao.UserDAO
import play.twirl.api.StringInterpolation
import models.User
import concurrent.{ExecutionContext, Future}
/**
 * This controller creates an `Action` to handle HTTP requests to the
 * application's home page.
 */
@Singleton
class UserController @Inject()(userDao: UserDAO, mcc:MessagesControllerComponents)
                                 (implicit ec: ExecutionContext)
  extends MessagesAbstractController(mcc) with Logging {
  import userForm._
  private val Home = Redirect(routes.UserController.index())


  def index() = Action {
    implicit request =>
    Ok (views.html.main("Welcome")(html"<div>Welcome to play framework</div>"))
  }

  def allUsers() = Action.async {
    implicit request =>
      userDao.all().map{ users =>
        Ok (views.html.users.index(users))
  }

  def getUserById(id: Long) =  Action.async {
    implicit request =>
      userDao.getById(id).map {emps =>
        emps match {
          case Seq(x, xs @ _*) =>
            Ok (views.html.index(emps))
          case Seq() => NotFound(views.html.main("Not Found")
          (html"<div>user not exists</div>"))
          case _ => Ok (views.html.index(emps))
        }
      }
  }
  def deleteUserById(id:Long)  = Action.async {
    implicit request =>
    userDao.deleteById(id)
      Future(Home)
  }

  def addUser() = Action.async {
    Future(Ok(views.html.users.newUsers()))
  }
}
