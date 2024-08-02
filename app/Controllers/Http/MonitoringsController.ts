import type { HttpContextContract } from '@ioc:Adonis/Core/HttpContext'

export default class MonitoringsController {
  public async indexAdmin({ view }: HttpContextContract) {
    return view.render('pages/admin/index')
  }

  public async create({ view }: HttpContextContract) {
    return view.render('pages/admin/create')
  }

  public async store({}: HttpContextContract) {}

  public async show({}: HttpContextContract) {}

  public async edit({}: HttpContextContract) {}

  public async update({}: HttpContextContract) {}

  public async destroy({}: HttpContextContract) {}
}
