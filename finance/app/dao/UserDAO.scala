package dao

import javax.inject._
import play.api.db.slick.{DatabaseConfigProvider, HasDatabaseConfigProvider}
import slick.jdbc.JdbcProfile
import models.{User, Users}

import concurrent.{ExecutionContext, Future}
class UserDAO @Inject()
(protected val dbConfigProvider: DatabaseConfigProvider)(implicit executionContext: ExecutionContext)
  extends HasDatabaseConfigProvider[JdbcProfile] {
  import dbConfig.profile.api._

  import models.definitions.usersTable

  def all(): Future[Seq[Users]] = db.run(usersTable.result)

  def getById(id:Long): Future[Seq[Users]] =
    db.run( usersTable.filter(_.userId === id).result)

  def deleteById(id:Long) = db.run(usersTable.filter(_.userId === id).delete).map(_=> ())
}
