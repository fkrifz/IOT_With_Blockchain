import { DateTime } from 'luxon'
import { BaseModel, column } from '@ioc:Adonis/Lucid/Orm'

export default class IdentitasPerangkat extends BaseModel {
  @column({ isPrimary: true })
  public id: number

  @column()
  public nama_perangkat: string 

  @column()
  public lokasi_perangkat: string

  @column.dateTime({ autoCreate: true })
  public createdAt: DateTime

  @column.dateTime({ autoCreate: true, autoUpdate: true })
  public updatedAt: DateTime
}
