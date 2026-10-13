// tipo polimorfico
object sinRequisitos {
  method cumple(estudiante, materia) = true
}

class Correlativas {
  const materias
  method cumple(estudiante, materia) =
    materias.all({ m => estudiante.aproboMateria(m) })
}

class Creditos {
  const minimo

  method cumple(estudiante, materia) =
    estudiante.creditosAprobadosEn(materia.carrera()) >= minimo
}

object añoAnterior {
  method cumple(estudiante, materia) =
    materia.carrera().materiasDelaño(materia.año() - 1)
      .all({ m => estudiante.aproboMateria(m) })
}

//  dominio 
class Carrera {
  const property nombre
  const property materias = #{}

  method agregarMateria(materia) { materias.add(materia) }

  method materiasDelaño(año) = materias.filter({ m => m.año() == año })
}

class Materia {
  const property nombre
  const property carrera
  const property año = 1
  const property creditos = 8
  var property requisito = sinRequisitos
  const property inscriptos = #{}

  method initialize() {
    carrera.agregarMateria(self)
 }

  method cumpleRequisitos(estudiante) = requisito.cumple(estudiante, self)
  method estaInscripto(estudiante) = inscriptos.contains(estudiante)
  method inscribir(estudiante) { inscriptos.add(estudiante) }
}

class Cursada {
  const property materia
  const property nota
  method aprobada() = nota >= 6
}

class Estudiante {
  const property nombre
  const property carreras = #{}
  const cursadas = []




  //  Parte 1 
  method inscribirseA(carrera) {
    if (self.estaInscriptoEn(carrera)) {
      throw new DomainException(message = "Ya está inscripta en " + carrera.nombre())
    }
    carreras.add(carrera)
  }

  method estaInscriptoEn(carrera) = carreras.contains(carrera)
  method cursaMateria(materia) = carreras.contains(materia.carrera())




  // Parte 2 
  method registrarCursada(materia, nota) {
    if (!nota.between(1, 10)) {
      throw new DomainException(message = "La nota debe estar entre 1 y 10")
    }
    if (self.aproboMateria(materia)) {
      throw new DomainException(message = "Ya aprobó " + materia.nombre())
    }
    if (!self.cursaMateria(materia)) {
      throw new DomainException(message = "No está inscripta en la carrera de " + materia.nombre())
    }
    cursadas.add(new Cursada(materia = materia, nota = nota))
  }

  method aproboMateria(materia) = cursadas.any({ c => c.materia() == materia && c.aprobada() })

  method cursadasDe(materia) = cursadas.filter({ c => c.materia() == materia })

  method cursadasAprobadas() = cursadas.filter({ c => c.aprobada() })

  method cursadasAprobadasEn(carrera) = self.cursadasAprobadas().filter({ c => c.materia().carrera() == carrera })

  method cantidadAprobadasEn(carrera) = self.cursadasAprobadasEn(carrera).size()

  method cantidadAprobadas() = self.cursadasAprobadas().size()

  method creditosAprobadosEn(carrera) = self.cursadasAprobadasEn(carrera).sum({ c => c.materia().creditos() })

  method promedioEn(carrera) {
    if (!self.estaInscriptoEn(carrera)) {
      throw new DomainException(message = "No está inscripta en " + carrera.nombre())
    }
    return self.promedioDe(self.cursadasAprobadasEn(carrera))
  }

  method promedioGeneral() = self.promedioDe(self.cursadasAprobadas())

  method promedioDe(unasCursadas) {
    if (unasCursadas.isEmpty()) {
      throw new DomainException(message = "No tiene materias aprobadas")
    }
    return unasCursadas.sum({ c => c.nota() }) / unasCursadas.size()
  }



  // Parte 3 
  method puedeInscribirseA(materia) =
    self.cursaMateria(materia)
      && !self.aproboMateria(materia)
      && !materia.estaInscripto(self)
      && materia.cumpleRequisitos(self)

  method inscribirseAMateria(materia) {
    if (!self.puedeInscribirseA(materia)) {
      throw new DomainException(message = "No puede inscribirse a " + materia.nombre())
    }
    materia.inscribir(self)
  }

  method materiasHabilitadasEn(carrera) =
    carrera.materias().filter({ m => self.puedeInscribirseA(m) })
}
