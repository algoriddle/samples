/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package algoriddle.s3;

import javax.persistence.*;

/**
 *
 * @author gszilvasy
 */
@Entity
@Table(indexes={
    @Index(columnList = "sha1"),
    @Index(columnList = "name", unique = true)
})
public class FileDescriptor {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private long id;  
  String name;
  String sha1;
  long modified; 
} 