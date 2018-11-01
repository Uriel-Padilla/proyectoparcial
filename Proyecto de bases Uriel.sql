/*
Autor : Uriel Gustavo Padilla Bustamante.
Institución : Universidad de la Sierra Sur.
Lugar : Miahuatlán de Porfirio Diaz Oaxaca, 31 de Octubre del 2018.
Asunto: Proyecto de base de datos 2 primer parcial.

Base de datos que registra datos de Jugadores y campeones así como los registro de las batallas en la cual participan. 
Un jugador puede contratar muchos campeones para combatir y puede contratarlos muchas veces .
 A continuación se implementa la base de datos además de los procedimientos almacenados y funciones para utilizar la base de datos.
 Los CRUD están incluidos de forma separada.

*/

CREATE DATABASE IF NOT EXISTS juego;

-- or

DROP DATABASE IF EXISTS juego;
CREATE DATABASE juego;


USE juego;

CREATE TABLE jugadores(
    idJugador INT NOT NULL AUTO_INCREMENT,
    nombreJugador VARCHAR(45) NOT NULL,
    nivel INT NULL,
    fecha DATE NOT NULL,
    edad int,
    CONSTRAINT jugadores_pk PRIMARY KEY(idJugador)
);

CREATE TABLE campeones(
    idCampeon INT NOT NULL AUTO_INCREMENT,
    nombreCampeon VARCHAR(45) NOT NULL,
    tipo VARCHAR(20) NOT NULL,
    precio DECIMAL(8,2) NULL,
    fecha DATE NOT NULL,
    edad int,
    CONSTRAINT campeones_clave_alt UNIQUE (nombreCampeon),
    CONSTRAINT campeones_pk PRIMARY KEY(idCampeon)
);

CREATE TABLE batallas(
    jugadorId INT NOT NULL,
    campeonId INT NOT NULL,
    cantidad INT NOT NULL,
    CONSTRAINT batallas_jugadores FOREIGN KEY (jugadorId)
        REFERENCES jugadores (idJugador)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT batallas_campeones FOREIGN KEY (campeonId)
        REFERENCES campeones (idCampeon)
        ON DELETE RESTRICT
        ON UPDATE CASCADE, 
        CONSTRAINT batallas_pk PRIMARY KEY  (jugadorId, campeonId)
);
/*
DELIMITER //
CREATE PROCEDURE `spCrearRegistroJugador` (
	IN _nombreJugador VARCHAR (45),
    IN _nivel INT,
    IN _fecha DATE,
    IN _edad INT
)
BEGIN
	INSERT INTO jugadores (
		nombreJugador, 
        nivel, 
        fecha,
        edad
	)
	VALUES(
		_nombreJugador,
        _nivel,
        _fecha,
        _edad
    );
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `spObtenerRegistroJugadorCampeones` (
	IN _nombreJugador VARCHAR (45)
)
BEGIN
	SELECT 
		j.nombreJugador, 
		c.nombreCampeon,
        b.cantidad
	FROM jugadores j
    INNER JOIN batallas b
    ON j.idJugador = b.jugadorId
    INNER JOIN campeones c
    ON b.campeonId = c.idCampeon
	WHERE j.nombreJugador = _nombreJugador;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `spCrearRegistroCampeon` (
	IN _nombreCampeon VARCHAR (45),
    IN _tipo VARCHAR(20),
    IN _precio DECIMAL(8,2),
    IN _fecha DATE,
    IN _edad INT
)
BEGIN
	INSERT INTO campeones (
		nombreCampeon, 
        tipo, 
        precio,
        fecha,
        edad
	)
	VALUES(
		_nombreCampeon,
        _tipo,
        _precio,
        _fecha,
        _edad
    );
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `spCrearRegistroBatallas` (
	IN _jugadorId INT,
    IN _campeonId INT,
    IN _cantidad INT
)
BEGIN
	INSERT INTO batallas (
		jugadorId, 
        campeonId, 
        cantidad
	)
	VALUES(
		_jugadorId,
        _campeonId,
        _cantidad
    );
END //
DELIMITER ;

DELIMITER //
CREATE FUNCTION `fnObtenerPrecioTotalCampeones` ()
	RETURNS DECIMAL(8,2)
	
    BEGIN
		DECLARE totalPrecio DECIMAL(8,2);
        SET totalPrecio = (SELECT SUM(precio) FROM campeones);
        RETURN totalPrecio;
    END //
DELIMITER ;

DELIMITER //
CREATE FUNCTION `fnObtenerTotalPagoJugador` (_nombreJugador VARCHAR(45))
	RETURNS DECIMAL(8,2)
	
    BEGIN
		DECLARE totalPago DECIMAL(8,2);
        SET totalPago = (SELECT 
						 SUM(c.precio * b.cantidad)
						 FROM jugadores j
						 INNER JOIN batallas b
						 ON j.idJugador = b.jugadorId
						 INNER JOIN campeones c
						 ON b.campeonId = c.idCampeon
						 WHERE j.nombreJugador = _nombreJugador
                         );
        RETURN totalPago;
    END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `spCRUDjugadores` (
	IN _idJugador INT,
    IN _nombreJugador VARCHAR(45),
    IN _nivel INT,
    IN _fecha DATE,
    IN _opcion VARCHAR (10)
)
BEGIN
	CASE
		WHEN _opcion='Create' THEN
			INSERT INTO jugadores (nombreJugador, nivel, fecha)	VALUES(_nombreJugador,_nivel,_fecha);
		WHEN _opcion='Read' THEN
			SELECT * FROM jugadores;
        WHEN _opcion='Update' THEN
			UPDATE jugadores SET nombreJugador = _nombreJugador, nivel = _nivel, fecha = _fecha WHERE idJugador = _idJugador;
        WHEN _opcion='Delete' THEN
			DELETE FROM jugadores WHERE idJugador = _idJugador;
    END CASE;
END //
DELIMITER ;


DELIMITER //
	CREATE FUNCTION `fnComparacionNumero`(val1 INT,val2 INT)
		RETURNS VARCHAR(20)
        BEGIN 
			DECLARE resultado VARCHAR(20);
            IF (val1>val2) THEN
				SET resultado = '>';
			ELSEIF val1 = val2 THEN
				SET resultado = '=';
			else
				SET resultado = '<';
			end if;
            SET resultado = concat(val1,'',resultado, '',val2);
            RETURN resultado;
        END //
DELIMITER ;

DELIMITER //


DELIMITER //
	CREATE FUNCTION `fnComparacionEdad`(edad INT)
		RETURNS VARCHAR(20)
        BEGIN 
			DECLARE resultado VARCHAR(20);
            IF (edad > 15 && edad <30) THEN
				SET resultado = 'joven';
			ELSEIF edad >= 30 THEN
				SET resultado = 'Adulto';
			else
				SET resultado = 'Niño';
			end if;
            RETURN resultado;
        END //
DELIMITER ;

CALL spCrearRegistroJugador('Salazar', 20, '2018-06-29');
CALL spCrearRegistroJugador('Jalmes', 10, '2018-07-15');
CALL spCrearRegistroJugador('Bernal', 30, '2018-09-24');
CALL spCrearRegistroJugador('Corona', NULL, '2018-12-25');

CALL spCrearRegistroCampeon('Akali', 'Aseseino', 790, '2018-05-11');
CALL spCrearRegistroCampeon('Brand', 'Aseseino', NULL, '2018-09-10');
CALL spCrearRegistroCampeon('Caitlyn', 'mago', 880, '2018-01-01');

CALL spCrearRegistroBatallas(1, 1, 300);
CALL spCrearRegistroBatallas(1, 2, 200);
CALL spCrearRegistroBatallas(1, 3, 400);
CALL spCrearRegistroBatallas(2, 1, 300);
CALL spCrearRegistroBatallas(2, 2, 400);
CALL spCrearRegistroBatallas(3, 2, 200);

*/
-- procedures y funciones 

-- 1.-procedimiento almacenado para crear un jugador
DELIMITER //
	create procedure `spCrearJugador`(
		IN _idJugador INT,
		IN _nombreJugador VARCHAR(45),
		IN _nivel INT,
		IN _fecha DATE,
        In _edad INT
    )
    begin
		insert into jugadores(
        idJugador,
        nombreJugador,
        nivel,
        fecha,
        edad
        )
        values(
		_idJugador,
        _nombreJugador,
        _nivel,
        _fecha,
        _edad
        );
        
    end //
DELIMITER ;

-- 2.- procedimiento almacenado para crear un campeón
DELIMITER //
	CREATE PROCEDURE `spCrearCampeon`(
		IN _nombreCampeon VARCHAR(45),
		IN _tipo VARCHAR(20),
		IN _precio DECIMAL(8,2),
		IN _fecha DATE,
        IN _edad INT
        )
	begin
		insert into campeones(nombreCampeon,tipo,precio,fecha,edad) values (_nombreCampeon,_tipo,_precio,_fecha,_edad);
    end //
DELIMITER ;


-- 3.-procedimiento almacenado para crear una batalla
DELIMITER //
CREATE PROCEDURE `spCrearRegistroBatallas` (
	IN _jugadorId INT,
    IN _campeonId INT,
    IN _cantidad INT
)
BEGIN
	INSERT INTO batallas (
		jugadorId, 
        campeonId, 
        cantidad
	)
	VALUES(
		_jugadorId,
        _campeonId,
        _cantidad
    );
END //
DELIMITER ;
-- 4.-procedimiento almacenado para actualizar un jugador
DELIMITER //
	CREATE PROCEDURE `spActualizarJugador`(
		IN _idJugador INT,
		IN _nombreJugador VARCHAR(45),
		IN _nivel INT,
		IN _fecha DATE,
        IN _edad INT
    )
    BEGIN
		UPDATE jugadores 
        SET nombreJugador = _nombreJugador,
        nivel = _nivel,
        fecha = _fecha,
        edad = _edad
        WHERE idJugador = _idJugador;
    END//
DELIMITER ;

-- 5.-procedimiento almacenado para actualizar un campeon 
DELIMITER //
	CREATE PROCEDURE `spActualizarCampeon`(
		IN _nombreCampeon VARCHAR(45),
		IN _tipo VARCHAR(20),
		IN _precio DECIMAL(8,2),
		IN _fecha DATE,
        IN _edad INT
    )
    BEGIN
		UPDATE campeones
        SET nombreCampeon = _nombreCampeon,
        tipo = _tipo,
        precio = _precio,
        fecha = _fecha,
        edad = _edad
        WHERE idCampeon = _idCampeon;
    END//
DELIMITER ;

-- 6.- procedimiento almacenado para actualizar una batalla
DELIMITER //
CREATE PROCEDURE `spActualizarBatallas`(
	IN _jugadorId INT,
    IN _campeonId INT,
    IN _cantidad INT
)
BEGIN
	UPDATE batallas
	SET 
	cantidad = _cantidad
	WHERE  jugadorId = _jugadorId and campeonId = _campeonId;
END //
DELIMITER ;



-- 7.- procedimiento almacenado para eliminar un jugador
DELIMITER //
	CREATE PROCEDURE `spEliminarJugador`(
		IN _idJugador INT
    )
    BEGIN
		DELETE FROM jugadores WHERE idJugador = _idJugador;
    END//
DELIMITER ;


-- 8.- procedimiento almacenado para eliminar un campeon
DELIMITER //
	CREATE PROCEDURE `spEliminarCampeon`(
		IN _idCampeon INT
    )
    BEGIN

       DELETE FROM campeones WHERE idCampeon = _idCampeon;
    END//
DELIMITER ;

-- 9.- procedimiento almacenado para eliminar batallas 
DELIMITER //
CREATE PROCEDURE `spEliminarBatallas`(
	IN _jugadorId INT,
    IN _campeonId INT
)
BEGIN
	UPDATE batallas
	SET 
	cantidad = _cantidad
	WHERE  jugadorId = _jugadorId and campeonId = _campeonId;
END //
DELIMITER ;

-- 10.- procedimiento almacenado para obtener jugadores
DELIMITER //
CREATE PROCEDURE `spObtnerRegistrosJugadores`()
BEGIN
	select * from jugadores;
END //
DELIMITER ;
-- 11.- procedimiento almacenado para obtener Campeones
DELIMITER //
CREATE PROCEDURE `spObtnerRegistrosCampeones`()
BEGIN
	select * from campeones;
END //
DELIMITER ;

-- 12.- procedimiento almacenado para obtener batallas 
DELIMITER //
CREATE PROCEDURE `spObtnerRegistrosBatallas`()
BEGIN
	select * from batallas;
END //
DELIMITER ;



-- 13.- procedimiento almacenado para obtener un jugador especifico
DELIMITER //
CREATE PROCEDURE `spObtnerRegistroJugadores`(
IN _jugadorId int )
BEGIN
	select * from batallas where jugadorId = _jugadorId ;
END //
DELIMITER ;


-- 14.- procedimiento almacenado para obtener un campeon especifico
DELIMITER //
CREATE PROCEDURE `spObtnerRegistroCampeon`(
IN _idCampeones int  )
BEGIN
	select * from campeones where  idCampeones = _CampeonesId ;
END //
DELIMITER ;


-- 15.- procedimiento almacenado para obtener jugadores que han combatido o no 
DELIMITER //
CREATE PROCEDURE `spJugadoresActivosyNoactivosCampeon`()
BEGIN
    select j.nombreJugador,c.nombreCampeon from jugadores j left outer join batallas b
    on j.idJugador=b.jugadorId left outer join campeones c
    on b.campeonId=c.idCampeon;
END //
DELIMITER;

-- 16 procedimiento almacenado para obtener a los jugadores que han combatido y el numero de veces que a jugado con ese campeon
DELIMITER //
CREATE PROCEDURE `spObtnerJugadoresCombatidoNum`()
BEGIN
	select j.nombreJugador, c.nombreCampeon, b.cantidad batallas
    from jugadores j inner join batallas b on idJugador=JugadorId
    inner join campeones c on b.	campeonId = c.idCampeon ;
END //
DELIMITER ;
-- 17 procedimiento almacenado para obtener los campeones mas contratados
DELIMITER //
CREATE PROCEDURE `spObtnerCampeonesMAsContratados`()
BEGIN
	select nombreCampeon
    from campeones where Idcampeon in (select campeonId from batallas where batallas.cantidad  = (select max(cantidad) from batallas));
END //
DELIMITER ;
-- 18.- Obtener los jugadores menos contratados 
DELIMITER //
CREATE PROCEDURE `spObtnerCampeonesMenosContratados`()
BEGIN
	select nombreCampeon
    from campeones where Idcampeon in (select campeonId from batallas where batallas.cantidad  = (select min(cantidad) from batallas));
END //
DELIMITER ;

-- 19.- procedimiento almacenado que muestra los jugadores que han gastado mas en contratar campeones
DELIMITER //
	CREATE PROCEDURE `spJugadoresQueMasHanGastado`()
	BEGIN
	    select nombreJugador, MAX(cantidad*precio) from jugadores j inner join batallas b on j.idJugador=b.jugadorId
	    inner join campeones c on b.campeonId=c.idCampeon;
	END //
	DELIMITER ;

-- 21.- Procedimiento para obtener los jugadores jovenes donde seran los que sean menores a 25 años al menos para mi implementación
DELIMITER //
	CREATE PROCEDURE `spComparacionEdadMenores`(
    )
        BEGIN 
			select * from jugadores where edad < 25 ;
        END //
DELIMITER ;

-- 22.- Procedimiento para obtener los jugadores adultos donde seran los que sean mayores o igual a 25 años al menos para mi implementación
DELIMITER //
	CREATE PROCEDURE `spComparacionEdadMayores`(
    )
        BEGIN 
			select * from jugadores where edad >= 25 ;
        END //
DELIMITER ;

-- 23.- procedimiento almacendado para obtener los jugadores que no han participado en batallas
DELIMITER //
	CREATE PROCEDURE `spJugadoresNoParticipaciones`(
    )
        BEGIN 
			select j.nombreJugador
			from jugadores j left outer join batallas b on  idJugador=JugadorId where b.jugadorId is null ;
        END //
DELIMITER ;



-- 24.- procedimiento almacendado para obtener los campeones  que no han sido contratados
DELIMITER //
	CREATE PROCEDURE `spCampeonesNoParticipaciones`(
    )
        BEGIN 
			select c.nombreCampeon
			from campeones c left outer join batallas b on  idCampeon=campeonId where b.campeonId is null ;
        END //
DELIMITER ;
-- 25.- Procedimiento almacenado para obtener los jugadores o el jugador con el nivel mas alto
DELIMITER //
	CREATE PROCEDURE `spJugadorAlto`(
    )
        BEGIN 
			 select * from jugadores where nivel =(select max(nivel) from jugadores);
        END //
DELIMITER ;

-- 26 función para obtener los jugadores que no cobran
DELIMITER //
CREATE FUNCTION `fnCampeonesVoluntarios`()
returns VARCHAR(20)
BEGIN
	declare nombre varchar(20);
    set nombre=(select nombreCampeon from campeones where precio is NULL);
    return nombre;
END //
DELIMITER ;

-- 27 función para obtener el total de jugadores 
DELIMITER //
CREATE FUNCTION `fnTotalJugadores`()
RETURNS INTEGER
BEGIN
	DECLARE total INTEGER;
	SET total = (SELECT COUNT(nombreJugador) FROM jugadores);
	RETURN total;
END //
DELIMITER ;

-- 28 función para obtener el total de campeones
DELIMITER //
CREATE FUNCTION `fnTotalCampeones`()
RETURNS INTEGER
BEGIN
	DECLARE total INTEGER;
	SET total=(SELECT COUNT(nombrecampeon) FROM campeones);
	RETURN total;
END //
DELIMITER ;

-- 29.-  FUNCION PARA OBTENER EL TOTAL QUE HA GASTADO UN JUGADOR EN CONTRATAR CAMPEONES
DELIMITER //
CREATE FUNCTION `fnTotalGastoJugador`(_idJugador INT)
RETURNS DECIMAL(8,2)
BEGIN
	DECLARE total DECIMAL(8,2);
    set total=(SELECT sum(b.cantidad*c.precio) from jugadores j
    INNER JOIN batallas b ON j.idJugador = b.jugadorId
    INNER JOIN campeones c ON b.campeonId = c.idCampeon
    WHERE j.idJugador=_idJugador);
    return total;
END //
DELIMITER;


-- 30 funcion que retorna si un jugador es joven o adulto
DELIMITER //
CREATE FUNCTION `fnEsAdultoOJovenJugador`(_idJugador INT)
	RETURNS varchar(25)
	BEGIN
    declare _edad int;
    declare mensaje varchar(25);
	set _edad=(select edad from jugadores 
    where idJugador=_idJugador);
    IF _edad <25 then
		set mensaje="Joven";
	else
		set mensaje="Adulto";
	end if;
    return mensaje;
	END //
DELIMITER ;

-- 31 funcion que retorna si un campeon es joven  o adulto
DELIMITER //
CREATE FUNCTION `fnesAdultoOJovenCampeon`(_idCampeon INT)
	RETURNS varchar(25)
	BEGIN
    declare _edad int;
    declare mensaje varchar(20);
	set _edad=(select años from campeones
    where idcampeon=_idCampeon);
    IF _edad <18 then
		set mensaje="Joven";
	else
		set mensaje="Adulto";
	end if;
    return mensaje;
	END //
DELIMITER ;

-- 33.- funcion para obtener cuantas veces ha contraado un jugador a un campeón.
DELIMITER //
CREATE FUNCTION `fnTotalContratoJugadorConCampeon`(_idJugador INT,_idCampeon INT)
RETURNS INT
BEGIN
	DECLARE total int;
    set total=(SELECT sum(b.cantidad) from jugadores j
    INNER JOIN batallas b ON j.idJugador = b.jugadorId
    INNER JOIN campeones c ON b.campeonId = c.idCampeon
    WHERE j.idJugador=_idJugador AND c.idCampeon=_idCampeon);
    return total;
END //
DELIMITER ;


call spCrearJugador(1,"Uriel",10,"2018-06-29",10);
call spCrearJugador(2,"Pedro",13,"2018-06-29",15);
call spCrearJugador(3,"Dano",12,"2018-06-29",16);
call spCrearJugador(4,"Luis",11,"2018-06-29",19);
call spCrearCampeon("Perez","principiante",10.3,"2018-06-29",17);
call spCrearCampeon("kali","cintinela",null,"2018-06-29",30);
call spCrearCampeon("master","asecino",200.3,"2018-06-29",25);
call spCrearRegistroBatallas(1,2,10);
call spCrearRegistroBatallas(3,2,3);
call spCrearRegistroBatallas(4,3,10);

-- call spObtnerJugadoresCombatidoONo();
call spObtnerJugadoresCombatidoNum();
call spObtnerCampeonesMAsContratados();
call spObtnerCampeonesMenosContratados();
-- call spObtnerPagoJugadores();
call spComparacionEdadMenores();
call spComparacionEdadMayores();
call spJugadoresNoParticipaciones();
call spCampeonesNoParticipaciones();
call spJugadorAlto();

